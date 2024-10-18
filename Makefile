ENV = env
PYTHON = $(ENV)/bin/python
PIP = $(ENV)/bin/pip
DJANGO_MANAGE = $(PYTHON) manage.py
AWS_REGION ?= us-east-1

# Make postgres available
docker-up:
	docker compose up --build --force-recreate

# Apply database migrations
migrate:
	$(DJANGO_MANAGE) migrate

# Run the Django development server
run:
	$(DJANGO_MANAGE) runserver

# Run unit tests
test:
	$(DJANGO_MANAGE) test

# Clean up the environment
clean:
	rm -rf $(ENV)

# Build for production
build-local:
	docker build -t django-app:latest .

# Run the application in a container (works for both windows and linux)
execute-local:
	docker run -e DB_HOST=host.docker.internal -p 8000:8000 --add-host=host.docker.internal:host-gateway django-app

# Set up the application (install, migrate, seed)
setup: docker-up migrate

# Run server and watch the logs
run_with_logs:
	$(DJANGO_MANAGE) runserver | tee server.log
