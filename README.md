# GeoBound

This project consists of a Django application with geolocation capabilities, using PostgreSQL and PostGIS that allows providers to verify all service areas registered near a given location (lat and lng).

## Requirements

Ensure before executing the project to have the following dependencies installed:

- Python 3.8+
- Make
- Python-pip
- Python venv
- Docker (PostgreSQL with PostGIS extension)
- Aws cli (for publishing the application)

> **Note**: It's also needed to setup the OS to be able to handle geolocalization features.
> For Debian users you can install the dependencies by running the following command:
>
> ```bash
> sudo apt-get install python3 python3-pip python3-venv make binutils libproj-dev gdal-bin libgdal-dev docker.io docker-compose-v2 -y
> ```

### Dependencies

```bash
make docker-up
```

# Project Setup

1. Clone the repository

```bash
git clone https://github.com/your-repo/Mozio-Project.git
cd Mozio-Project
python3 -m venv env
source env/bin/activate
pip3 install -r requirements.txt
```

2. Set up the application
You can set up the app by running the following Makefile commands:

```bash
make setup
```

> This will:
>
> Boot the database.
> Apply database migrations.

3. Run the development server

Start the Django development server:

```bash
make run
# Swagger available at the app at http://127.0.0.1:8000/swagger.
```

4. Run Tests
To run the tests, use the following command:

```bash
make test
```

5. Publish the application

First build locally the application:

```bash
make build-local
```

Now use terraform to create ECR on AWS inside the `deploy` folder and then push the local image to the ECR with the folloging commands:

```bash
 aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
 docker tag django-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/django-app:latest
 docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/django-app:latest
```

5. Clean Up
To clean up the project (remove the virtual environment), run the following:

```bash
make clean
```

## Additional Commands

`make migrate`: Apply database migrations </br>
`make seed`: Load initial data (seed the database). </br>
`make run_with_logs`: Run the server and output logs to server.log.
