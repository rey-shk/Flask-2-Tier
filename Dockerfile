# syntax=docker/dockerfile:1
FROM python:3.13-slim

WORKDIR /app

# Install build tools (optional, needed for some packages)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the Flask development server port
EXPOSE 5000

# Default command
CMD ["python", "app.py"]
