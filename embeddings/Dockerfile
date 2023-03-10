FROM python:3.10

COPY ./requirements.txt /code/requirements.txt
COPY ./app /code/app

#
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Download models from the internet and store in Docker image
RUN python code/app/clip/loadModel.py
RUN python code/app/minilm/loadModel.py

WORKDIR /code/app


#
#CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
CMD ["gunicorn", "main:app", "-b", "0.0.0.0:8000", "--timeout", "600", "-w", "1", "-k", "uvicorn.workers.UvicornWorker"]
EXPOSE 8000
