from flask import Flask, request, jsonify
from image_utils import analyze_image

app = Flask(__name__)

@app.route("/analyze", methods=["POST"])
def analyze():
    img_url = request.json["url"]
    result = analyze_image(img_url)
    return jsonify(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
