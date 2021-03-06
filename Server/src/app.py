
from flask import Flask, request, jsonify
import numpy as np
import cv2 as cv
import base64


app = Flask(__name__)


@app.route('/', methods=['GET'])
def home():
    return "<h1>Hola Mundo</h1>"


@app.route("/opencv", methods=['GET', "POST"])
def openCv():
    if request.method == "POST":

        aux = request.form["img"]
        if not aux:
            return "Error"
        cnt = 0

        decoded_data = base64.b64decode(aux)
        np_data = np.frombuffer(decoded_data, dtype=np.uint8)
        img = cv.imdecode(np_data, cv.IMREAD_COLOR)

        hsvim = cv.cvtColor(img, cv.COLOR_BGR2HSV)
        lower = np.array([0, 48, 80], dtype="uint8")
        upper = np.array([20, 255, 255], dtype="uint8")
        skinRegionHSV = cv.inRange(hsvim, lower, upper)
        blurred = cv.blur(skinRegionHSV, (2, 2))
        ret, thresh = cv.threshold(blurred, 0, 255, cv.THRESH_BINARY)

        contours, hierarchy = cv.findContours(
            thresh, cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
        contours = max(contours, key=lambda x: cv.contourArea(x))
        cv.drawContours(img, [contours], -1, (255, 255, 0), 2)

        hull = cv.convexHull(contours, returnPoints=False)
        defects = cv.convexityDefects(contours, hull)

        if defects is not None:
            cnt = 0
        for i in range(defects.shape[0]):
            s, e, f, d = defects[i][0]
            start = tuple(contours[s][0])
            end = tuple(contours[e][0])
            far = tuple(contours[f][0])
            a = np.sqrt((end[0] - start[0]) ** 2 + (end[1] - start[1]) ** 2)
            b = np.sqrt((far[0] - start[0]) ** 2 + (far[1] - start[1]) ** 2)
            c = np.sqrt((end[0] - far[0]) ** 2 + (end[1] - far[1]) ** 2)
            angle = np.arccos((b ** 2 + c ** 2 - a ** 2) /
                              (2 * b * c))
            if angle <= np.pi / 2:
                cnt += 1
                cv.circle(img, far, 4, [0, 0, 255], -1)
        if cnt > 0:
            cnt = cnt+1
        cv.putText(img, str(cnt), (0, 50), cv.FONT_HERSHEY_SIMPLEX,
                   1, (255, 0, 0), 2, cv.LINE_AA)

        return jsonify({"fingers": cnt})
    else:
        return "Error en el formato"


if __name__ == '__main__':
    app.run(port=80, debug=True)
