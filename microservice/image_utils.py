import requests
from PIL import Image
from io import BytesIO

def analyze_image(url):
    response = requests.get(url)
    img = Image.open(BytesIO(response.content))
    width, height = img.size
    return {"width": width, "height": height, "format": img.format}
