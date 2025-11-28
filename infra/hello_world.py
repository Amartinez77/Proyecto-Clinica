#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

class HelloWorldHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        
        response = {
            "message": "¡Hola Mundo! 🚀",
            "timestamp": datetime.now().isoformat(),
            "path": self.path,
            "status": "Tunnel works! ✓"
        }
        
        self.wfile.write(json.dumps(response, indent=2).encode())
    
    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 9999), HelloWorldHandler)
    print("🌍 Hola Mundo server listening on http://0.0.0.0:9999")
    print("Press Ctrl+C to stop")
    server.serve_forever()
