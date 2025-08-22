# -*- coding: utf-8 -*-
#!/usr/bin/env python3
import http.server
import socketserver
import os
import re

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

        content = re.sub(r'<!--#config[^>]*-->', '', content)
        content = re.sub(r'<!--#if[^>]*-->', '', content)
        content = re.sub(r'<!--#endif[^>]*-->', '', content)
        content = re.sub(r'<!--#echo[^>]*-->', '', content)

        return re.sub(pattern, replace_include, content)

PORT = 8000
with socketserver.TCPServer(("localhost", PORT), SSIHandler) as httpd:
    print(f"Server running at http://localhost:{PORT}")
    httpd.serve_forever()