from flask import Flask, request, jsonify
import subprocess
import logging

app = Flask(__name__)
app.logger.setLevel(logging.INFO)
app.logger.addHandler(logging.StreamHandler())

@app.route('/detect', methods=['POST'])
def detect_objects():
    # Check if an image file was sent
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    image_file = request.files['image']

    # Save the image to a temporary file
    image_path = 'temp_image.jpg'  # Replace with a valid path
    image_file.save(image_path)

    # Run the YOLO code as a subprocess and redirect the output to the logger
    command = ["yolo", "task=detect", "mode=predict", "model=./best.pt", "conf=0.55", f"source={image_path}"]
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    # Read and capture the command output from the subprocess
    command_output = ''
    class_name = ''
    for line in iter(process.stdout.readline, b''):
        line = line.decode().strip()
        command_output += line + '\n'
        app.logger.info(line)
        if line.startswith('image 1/1'):
            class_name = line.split(' ', 4)[-1].split(',', 1)[0].strip()

    # Wait for the subprocess to finish
    process.wait()

    if process.returncode == 0:
        return jsonify({'result': class_name}), 200
    else:
        error_message = process.stderr.read().decode().strip()
        app.logger.error(f"Error executing YOLO command: {error_message}")
        return jsonify({'error': 'Error executing YOLO command'}), 500

if __name__ == '__main__':
    app.run()