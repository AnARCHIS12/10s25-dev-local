#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import subprocess
import threading
import os
import sys
import http.server
import socketserver
import re
import webbrowser
from pathlib import Path
import io

class SSIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.endswith('.html') or self.path == '/':
            try:
                if self.path == '/':
                    filepath = 'index.html'
                else:
                    filepath = self.path.lstrip('/')
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                content = self.process_ssi(content)
                
                self.send_response(200)
                self.send_header('Content-type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(content.encode('utf-8'))
            except FileNotFoundError:
                super().do_GET()
        else:
            super().do_GET()
    
    def process_ssi(self, content):
        pattern = r'<!--#include virtual="([^"]+)" -->'
        
        def replace_include(match):
            include_path = match.group(1)
            try:
                with open(include_path, 'r', encoding='utf-8') as f:
                    return f.read()
            except FileNotFoundError:
                return f'<!-- File not found: {include_path} -->'
        
        # Supprimer les directives SSI non supportées
        content = re.sub(r'<!--#config[^>]*-->', '', content)
        content = re.sub(r'<!--#if[^>]*-->', '', content)
        content = re.sub(r'<!--#endif[^>]*-->', '', content)
        content = re.sub(r'<!--#echo[^>]*-->', '', content)
        
        return re.sub(pattern, replace_include, content)

class StandaloneDevGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("10s25 - Outils de Développement")
        self.root.geometry("700x500")
        self.root.configure(bg='#121214')
        
        # Icône de la fenêtre (favicon du projet)
        self.set_favicon_icon()
        
        self.server_process = None
        self.httpd = None
        self.project_path = None
        self.server_port = 8000
        
        self.setup_ui()
        
    def setup_ui(self):
        # Style
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('Title.TLabel', font=('Arial', 16, 'bold'), background='#121214', foreground='#f9e25b')
        
        # Logo et titre
        header_frame = tk.Frame(self.root, bg='#121214')
        header_frame.pack(pady=20)
        
        # Charger le logo du projet
        self.load_project_logo(header_frame)
        
        title = ttk.Label(header_frame, text="Outils de Développement", style='Title.TLabel')
        title.pack()
        
        # Frame principal
        main_frame = tk.Frame(self.root, bg='#121214')
        main_frame.pack(expand=True, fill='both', padx=20, pady=10)
        
        # Sélection du projet
        project_frame = tk.LabelFrame(main_frame, text="Projet", 
                                    bg='#f9e25b', fg='#000', font=('Arial', 12, 'bold'))
        project_frame.pack(fill='x', pady=10)
        
        tk.Button(project_frame, text="Sélectionner dossier projet", 
                 command=self.select_project, bg='#63ff43', fg='#000',
                 font=('Arial', 10, 'bold')).pack(side='left', padx=10, pady=10)
        
        self.project_label = tk.Label(project_frame, text="Aucun projet sélectionné", 
                                    bg='#f9e25b', fg='#000', font=('Arial', 9))
        self.project_label.pack(side='left', padx=10, pady=10)
        
        # Section Configuration
        config_frame = tk.LabelFrame(main_frame, text="Configuration", 
                                   bg='#f9e25b', fg='#000', font=('Arial', 12, 'bold'))
        config_frame.pack(fill='x', pady=10)
        
        tk.Button(config_frame, text="Configuration initiale", 
                 command=self.setup_project_scripts, bg='#63ff43', fg='#000',
                 font=('Arial', 10, 'bold')).pack(side='left', padx=10, pady=10)
        
        # Section Serveur Python
        python_frame = tk.LabelFrame(main_frame, text="Serveur Python Simple", 
                                   bg='#f9e25b', fg='#000', font=('Arial', 12, 'bold'))
        python_frame.pack(fill='x', pady=10)
        
        self.start_button = tk.Button(python_frame, text="Démarrer serveur", 
                 command=self.start_python_server, bg='#63ff43', fg='#000',
                 font=('Arial', 10, 'bold'))
        self.start_button.pack(side='left', padx=10, pady=10)
        
        tk.Button(python_frame, text="Ouvrir navigateur", 
                 command=self.open_browser,
                 bg='#f52639', fg='#fff', font=('Arial', 10, 'bold')).pack(side='left', padx=5, pady=10)
        
        tk.Button(python_frame, text="Arrêter", 
                 command=self.stop_python_server, bg='#222', fg='#fff',
                 font=('Arial', 10, 'bold')).pack(side='right', padx=10, pady=10)
        
        # Section Docker
        docker_frame = tk.LabelFrame(main_frame, text="Environnement Docker", 
                                   bg='#f9e25b', fg='#000', font=('Arial', 12, 'bold'))
        docker_frame.pack(fill='x', pady=10)
        
        tk.Button(docker_frame, text="Démarrer Docker", 
                 command=self.start_docker, bg='#63ff43', fg='#000',
                 font=('Arial', 10, 'bold')).pack(side='left', padx=10, pady=10)
        
        tk.Button(docker_frame, text="Apache (8080)", 
                 command=lambda: webbrowser.open('http://localhost:8080'),
                 bg='#f52639', fg='#fff', font=('Arial', 10, 'bold')).pack(side='left', padx=5, pady=10)
        
        tk.Button(docker_frame, text="Live reload (3000)", 
                 command=lambda: webbrowser.open('http://localhost:3000'),
                 bg='#f52639', fg='#fff', font=('Arial', 10, 'bold')).pack(side='left', padx=5, pady=10)
        
        tk.Button(docker_frame, text="BrowserSync (3001)", 
                 command=lambda: webbrowser.open('http://localhost:3001'),
                 bg='#f52639', fg='#fff', font=('Arial', 10, 'bold')).pack(side='left', padx=5, pady=10)
        
        tk.Button(docker_frame, text="Arrêter Docker", 
                 command=self.stop_docker, bg='#222', fg='#fff',
                 font=('Arial', 10, 'bold')).pack(side='right', padx=10, pady=10)
        
        
        # Status
        self.status_label = tk.Label(main_frame, text="Prêt - Sélectionnez un projet", 
                                   bg='#121214', fg='#63ff43', font=('Arial', 10))
        self.status_label.pack(pady=10)
        
    def select_project(self):
        folder = filedialog.askdirectory(title="Sélectionner le dossier du projet")
        if folder:
            self.project_path = folder
            self.project_label.config(text=f"Projet: {os.path.basename(folder)}")
            self.status_label.config(text="Projet sélectionné", fg='#63ff43')
    
    def open_browser(self):
        if self.httpd:
            webbrowser.open(f'http://localhost:{self.server_port}')
        else:
            # Essayer le port par défaut
            webbrowser.open('http://localhost:8000')
    
    def start_python_server(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
            
        if self.httpd is None:
            def start_server():
                try:
                    self.status_label.config(text="Démarrage serveur...", fg='#f9e25b')
                    os.chdir(self.project_path)
                    
                    # Essayer plusieurs ports
                    ports = [8000, 8001, 8002, 8003]
                    for port in ports:
                        try:
                            self.httpd = socketserver.TCPServer(("localhost", port), SSIHandler)
                            self.server_port = port
                            self.status_label.config(text=f"Serveur Python démarré sur :{port}", fg='#63ff43')
                            self.httpd.serve_forever()
                            break
                        except OSError:
                            continue
                    else:
                        self.status_label.config(text="Tous les ports occupés", fg='#f52639')
                except Exception as e:
                    self.status_label.config(text=f"Erreur: {str(e)[:50]}", fg='#f52639')
            
            threading.Thread(target=start_server, daemon=True).start()
        else:
            messagebox.showinfo("Info", "Le serveur est déjà en cours d'exécution")
    
    def stop_python_server(self):
        def stop_server():
            try:
                if self.httpd:
                    self.httpd.shutdown()
                    self.httpd.server_close()
                    self.httpd = None
                    self.status_label.config(text="Serveur Python arrêté", fg='#63ff43')
                    self.start_button.config(text="Démarrer serveur")
                else:
                    self.status_label.config(text="Aucun serveur en cours", fg='#f9e25b')
            except Exception:
                self.httpd = None
                self.status_label.config(text="Serveur arrêté (forcé)", fg='#63ff43')
                self.start_button.config(text="Démarrer serveur")
        
        threading.Thread(target=stop_server, daemon=True).start()
    
    def setup_project_scripts(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
        
        def run_setup():
            try:
                self.status_label.config(text="Configuration en cours...", fg='#f9e25b')
                os.chdir(self.project_path)
                
                # Détecter le système d'exploitation
                if os.name == 'nt':  # Windows
                    subprocess.run(['dev\\setup.bat'], shell=True, check=True)
                else:  # Linux/macOS
                    subprocess.run(['./dev/setup.sh'], check=True)
                    
                self.status_label.config(text="Configuration terminée", fg='#63ff43')
            except Exception as e:
                self.status_label.config(text=f"Erreur config: {str(e)[:30]}", fg='#f52639')
        
        threading.Thread(target=run_setup, daemon=True).start()
    
    def setup_project(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
        
        try:
            os.chdir(self.project_path)
            
            # Créer dossiers
            os.makedirs(os.path.join('local', 'ssi'), exist_ok=True)
            os.makedirs(os.path.join('global', 'ssi'), exist_ok=True)
            os.makedirs('dev', exist_ok=True)
            
            # Menu
            with open(os.path.join('local', 'ssi', 'menu_top.shtml'), 'w', encoding='utf-8') as f:
                f.write('''<!-- Éléments de menu principal personnalisé pour ce site -->
<li><a href="/local/visuels.html">Visuels</a></li>
<li class="dropdown">
	<a href="#" class="disabled">Doléances ▾</a>
	<ul class="submenu">
		<li><a href="/local/formulaire-doleances.html">Formulaire de Doléances</a></li>
		<li><a href="/local/doleances.html">Cahier de Doléances</a></li>
	</ul>
</li>''')
            
            # Fichiers SSI
            emails_path = os.path.join('local', 'ssi', 'emails.shtml')
            if not os.path.exists(emails_path):
                with open(emails_path, 'w') as f:
                    f.write('<a href="mailto:contact@example.com">contact@example.com</a>')
            
            gpg_path = os.path.join('local', 'ssi', 'gpg.shtml')
            if not os.path.exists(gpg_path):
                with open(gpg_path, 'w') as f:
                    f.write('Clé GPG à configurer')
            
            # Groupes basique
            with open(os.path.join('global', 'ssi', 'groupes.shtml'), 'w', encoding='utf-8') as f:
                f.write('''<ul class="sidebar-section-1">
    <li>
        <h3 class="font-yellow">Réseaux sociaux</h3>
        <ul class="sidebar-section-2">
            <li>
                <ul>
                    <li class="telegram">
                        <p>Telegram</p>
                        <ul>
                            <li><a href="https://t.me/+B5CJp-RUGpAzMmQ8" target="_blank" rel="me">+B5CJp-RUGpAzMmQ8</a></li>
                        </ul>
                    </li>
                </ul>
            </li>
        </ul>
    </li>
</ul>''')
            
            self.status_label.config(text="Fichiers créés avec succès", fg='#63ff43')
            
        except Exception as e:
            self.status_label.config(text=f"Erreur: {str(e)[:50]}", fg='#f52639')
    
    def start_docker(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
        
        def run_docker():
            try:
                self.status_label.config(text="Démarrage Docker...", fg='#f9e25b')
                os.chdir(self.project_path)
                
                # Détecter le système d'exploitation
                if os.name == 'nt':  # Windows
                    subprocess.run(['dev\\docker.bat'], shell=True, check=True)
                else:  # Linux/macOS
                    subprocess.run(['./dev/docker.sh'], check=True)
                    
                self.status_label.config(text="Docker démarré", fg='#63ff43')
            except Exception as e:
                self.status_label.config(text=f"Erreur Docker: {str(e)[:30]}", fg='#f52639')
        
        threading.Thread(target=run_docker, daemon=True).start()
    
    def stop_docker(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
        
        def stop_docker_process():
            try:
                self.status_label.config(text="Arrêt Docker...", fg='#f9e25b')
                os.chdir(self.project_path)
                
                # Détecter le système d'exploitation
                if os.name == 'nt':  # Windows
                    subprocess.run(['dev\\docker-stop.bat'], shell=True, check=True)
                else:  # Linux/macOS
                    subprocess.run(['./dev/docker-stop.sh'], check=True)
                    
                self.status_label.config(text="Docker arrêté", fg='#63ff43')
            except Exception as e:
                self.status_label.config(text=f"Erreur arrêt: {str(e)[:30]}", fg='#f52639')
        
        threading.Thread(target=stop_docker_process, daemon=True).start()
    
    def create_htaccess(self):
        if not self.project_path:
            messagebox.showerror("Erreur", "Veuillez sélectionner un projet d'abord")
            return
        
        try:
            os.chdir(self.project_path)
            
            # .htaccess principal
            with open('.htaccess', 'w') as f:
                f.write('''Options +Includes +FollowSymLinks
AddType text/html .shtml .html
AddOutputFilter INCLUDES .shtml .html
AddHandler server-parsed .html
DirectoryIndex index.html
XBitHack on

# Configuration pour la production
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</IfModule>

# Cache pour les ressources statiques
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
</IfModule>''')
            
            # .htaccess SSI legacy
            os.makedirs(os.path.join('local', 'ssi'), exist_ok=True)
            with open(os.path.join('local', 'ssi', '.htaccess'), 'w') as f:
                f.write('SSILegacyExprParser on')
            
            self.status_label.config(text="Fichiers .htaccess créés (avec sécurité)", fg='#63ff43')
            
        except Exception as e:
            self.status_label.config(text=f"Erreur: {str(e)[:50]}", fg='#f52639')
    
    def set_favicon_icon(self):
        # Utiliser le favicon.ico du projet
        favicon_paths = [
            'favicon.ico',
            os.path.join('..', 'favicon.ico'),
            os.path.join('..', '..', 'favicon.ico')
        ]
        
        for favicon_path in favicon_paths:
            if os.path.exists(favicon_path):
                try:
                    self.root.iconbitmap(favicon_path)
                    return
                except Exception:
                    continue
        
        # Fallback: icône par défaut
        try:
            self.root.iconbitmap('icon.ico')
        except:
            pass
    
    def set_icon(self):
        # Créer une icône intégrée
        try:
            import tkinter as tk
            from PIL import Image, ImageDraw, ImageTk
            
            # Créer image 32x32
            img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            
            # Fond jaune
            draw.rectangle([2, 2, 30, 30], fill='#F9E25B', outline='#121214', width=1)
            
            # Texte simple
            draw.text((16, 12), "10", fill='#121214', anchor='mm')
            draw.text((16, 22), "25", fill='#F52639', anchor='mm')
            
            # Convertir en PhotoImage
            photo = ImageTk.PhotoImage(img)
            self.root.iconphoto(True, photo)
            
        except Exception:
            # Si erreur, pas d'icône
            pass
    
    def load_project_logo(self, parent):
        # Essayer de charger le logo SVG du projet
        logo_paths = [
            os.path.join('global', 'img', 'logo-inbt.svg'),
            os.path.join('..', 'global', 'img', 'logo-inbt.svg'),
            os.path.join('..', '..', 'global', 'img', 'logo-inbt.svg')
        ]
        
        # Créer le frame du logo
        logo_frame = tk.Frame(parent, bg='#121214')
        logo_frame.pack(pady=(0, 10))
        
        logo_loaded = False
        for logo_path in logo_paths:
            if os.path.exists(logo_path):
                try:
                    # Essayer de convertir SVG en image
                    from PIL import Image, ImageTk
                    import cairosvg
                    
                    # Convertir SVG en PNG
                    png_data = cairosvg.svg2png(url=logo_path, output_width=200)
                    img = Image.open(io.BytesIO(png_data))
                    photo = ImageTk.PhotoImage(img)
                    
                    # Afficher l'image
                    logo_label = tk.Label(logo_frame, image=photo, bg='#121214')
                    logo_label.image = photo  # Garder une référence
                    logo_label.pack()
                    
                    logo_loaded = True
                    break
                except Exception:
                    continue
        
        if not logo_loaded:
            # Fallback: texte du projet
            text_frame = tk.Frame(logo_frame, bg='#F9E25B', relief='raised', bd=2)
            text_frame.pack()
            
            tk.Label(text_frame, text="INDIGNONS-NOUS", bg='#F9E25B', fg='#121214', 
                    font=('Arial', 14, 'bold')).pack(padx=20, pady=2)
            tk.Label(text_frame, text="BLOQUONS TOUT", bg='#F9E25B', fg='#F52639', 
                    font=('Arial', 16, 'bold')).pack(padx=20, pady=2)
            tk.Label(text_frame, text="DEV TOOLS", bg='#F9E25B', fg='#121214', 
                    font=('Arial', 8)).pack(padx=20, pady=(0, 5))
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = StandaloneDevGUI()
    app.run()