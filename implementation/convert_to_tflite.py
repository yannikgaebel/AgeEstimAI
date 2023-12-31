import tensorflow as tf
import numpy as np

# Convert the model to TFLite

# load the model
eff_net_model = tf.keras.models.load_model('full_model_trained.h5')
eff_net_model.summary()

# convert the model
converter = tf.lite.TFLiteConverter.from_keras_model(eff_net_model)
tflite_model = converter.convert()

# save the model
with open('model_test.tflite', 'wb') as f:
  f.write(tflite_model)


# Lets check TFLite model with sample image
  
# load the TFLite model
interpreter = tf.lite.Interpreter(model_path="./model weights/model.tflite")
interpreter.allocate_tensors()

# load the test image
IMG_SIZE = 200
file_path = './model weights/test_image.jpg'
img = tf.image.decode_jpeg(tf.io.read_file(file_path), channels=3)
img = tf.image.resize(img, [IMG_SIZE, IMG_SIZE])
input_data = np.expand_dims(img, axis=0).astype(np.float32) # add batch dimension

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# set the tensor to point to the input 
interpreter.set_tensor(input_details[0]['index'], input_data)

# run the inference
interpreter.invoke()

output_data = interpreter.get_tensor(output_details[0]['index'])
estimated_age = output_data[0][0]
print(f'Estimated Age: {estimated_age}')