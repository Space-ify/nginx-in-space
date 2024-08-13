![image](https://github.com/user-attachments/assets/471d95cd-e05c-4528-af9e-74bbd6b96da9)


**Users connects:** A user connects to [spacify.spacify.co](http://space.spaceify.co). 
The domain name space.spaceify.co is resolved by DNS (Domain Name System) to the IP address of the EC2 server on AWS (the EC2 instance running the NGINX container).
```python
version: "3"
services:
  nginx:
    image: nginx:alpine
    container_name: "space-nginx"
    build:
      context: "."
    ports:
      - "80:80"
    networks:
      - spaceify
networks:
  spaceify:
    external:
      name: spaceify
```
```python
ports:
      - "80:80"
```
This publishes port 80 for the docker container. Normally this is done with the -p flag when running a docker container manually:
```python
docker run -ti my-docker-hub-account/my-image -p 8085:8085
```
**Port Mapping:** The NGINX container listens on port 80 inside the container, and this port is mapped to port 80 on the EC2 instance. 
This means that when users access port 80 on the EC2 instance, the traffic is directed to port 80 inside the NGINX container.
The user is directed by NGINX to the correct resource based on the route passed in on the HTTP request ("/" vs "/api"). 

NGINGX Config
```python
worker_processes 1;
events { worker_connections 1024; }

http {
	limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
  limit_conn_zone $binary_remote_addr zone=addr:10m;

	server {
	    server_name space.spaceify.co www.space.spaceify.co; # Add more subdomains if needed
	    listen 80 ;

	    location / {
        proxy_pass http://frontend-in-space:3000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	    }

	    location /api/ {
        proxy_pass http://api-but-space:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        add_header Access-Control-Allow-Origin *;
	    }
	}
}
```

# Why Use a Reverse Proxy?
### Single Entry Point:
* The reverse proxy (NGINX) provides a single entry point for users, simplifying access to the application. Users only need to interact with one domain and port (port 80) rather than multiple services on different ports.
### Internal Request Routing:
* NGINX can route different types of requests to different backend services.
* For example, it can direct / requests to the React frontend and /api/ requests to the FastAPI backend. This keeps the service architecture clean and avoids exposing multiple ports.
* Directly exposing multiple services on different ports can be less secure and harder to manage. For example, exposing the React frontend on one port and the FastAPI backend on another may lead to additional security risks and complicate client-side configuration.
### Load Balancing:
* NGINX can distribute incoming traffic across multiple instances of backend services, which helps in scaling the application and balancing the load.
### Easy CORS Managment:
* The add_header Access-Control-Allow-Origin *; directive allows your frontend to make requests to the backend API from a different domain, facilitating cross-origin requests.
