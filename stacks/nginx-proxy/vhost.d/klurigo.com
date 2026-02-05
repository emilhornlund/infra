# Server context
client_max_body_size 50m;
# Optional: quick debug to prove this vhost.d is applied
add_header X-Nginx-Proxy "klurigo.com-server" always;
