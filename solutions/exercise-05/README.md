# Exercise 05

This code deploys two "microservices": a frontend that returns HTML and a backend that returns JSON. Both microservices
are built on top of a module that runs them in an Auto Scaling Group (ASG) with an Application Load Balancer (ALB) in 
front of it. The frontend talks to the backend via the backend's ALB.