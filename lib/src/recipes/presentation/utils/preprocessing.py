import tensorflow as tf
import numpy as np
from PIL import Image

# Load the TensorFlow Lite model
interpreter = tf.lite.Interpreter(model_path=r"D:\Pranav\dribbble_recipe_challenge\assets\models\trained_model.tflite")

# Allocate tensors
interpreter.allocate_tensors()

# Get input and output tensor details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Print input shape and data type
print("Input shape:", input_details[0]['shape'])
print("Input data type:", input_details[0]['dtype'])

# Print output shape and data type
print("Output shape:", output_details[0]['shape'])
print("Output data type:", output_details[0]['dtype'])

# Load an image for inference
image_path = r'D:\Project_Foody\codes\Models\Annotated_Data\train\images\0001_Bittergourd_train.jpg'  # Update with the path to your image
image = Image.open(image_path)

# Resize the image to match the input size of the model (640x640)
image = image.resize((640, 640))

# Convert the image to a numpy array and normalize it
image_np = np.array(image, dtype=np.float32)  # Convert to float32
image_np = np.expand_dims(image_np, axis=0)  # Add batch dimension

# Normalize the image values (if necessary)
image_np = image_np / 255.0  # Normalize to [0, 1] if the model expects normalized input

# Ensure input tensor is compatible with the model's expected shape
input_data = np.array(image_np, dtype=np.float32)

# Set the input tensor
interpreter.set_tensor(input_details[0]['index'], input_data)

# Run inference
interpreter.invoke()

# Get the output tensor
output_data = interpreter.get_tensor(output_details[0]['index'])

# Process the output (Example: if it's in YOLO format)
# Assuming output is in YOLO format, you would process it as follows
confidence_threshold = 0.5
output_data = output_data[0]  # Remove batch dimension

# Debug print the output data
print("Output data:", output_data)

# Example processing for YOLO output format [x, y, width, height, confidence, class_prob]
objects = []
for detection in output_data:
    x, y, width, height, confidence, class_prob = detection
    
    # Ensure confidence is a scalar (in case it's an array)
    if isinstance(confidence, np.ndarray):
        print(f"Confidence array: {confidence}")
        if confidence.size == 1:
            confidence = confidence.item()  # Convert to scalar if it's an array of size 1
        else:
            raise ValueError("Confidence score is an array with more than one element")
    
    if confidence > confidence_threshold:  # Compare confidence as a scalar
        # Assuming class scores start from index 5
        predicted_class = int(class_prob)  # Ensure class_prob is treated as a single value
        score = class_prob  # Use class_prob as the score

        objects.append({
            'x': x,
            'y': y,
            'width': width,
            'height': height,
            'confidence': confidence,
            'class': predicted_class,
            'score': score
        })

# Print detected objects
for idx, obj in enumerate(objects):
    print(f"Object {idx+1}: {obj}")