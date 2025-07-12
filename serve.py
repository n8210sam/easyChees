#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys

# Change to the build/web directory
web_dir = os.path.join(os.path.dirname(__file__), 'build', 'web')
if os.path.exists(web_dir):
    os.chdir(web_dir)
    print(f"Serving from: {web_dir}")
else:
    print(f"Error: Directory {web_dir} does not exist")
    sys.exit(1)

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        super().end_headers()

Handler = MyHTTPRequestHandler

try:
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Server running at http://localhost:{PORT}/")
        print("Press Ctrl+C to stop the server")
        httpd.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped.")
except OSError as e:
    if e.errno == 10048:  # Address already in use
        print(f"Port {PORT} is already in use. Try a different port.")
    else:
        print(f"Error starting server: {e}")
