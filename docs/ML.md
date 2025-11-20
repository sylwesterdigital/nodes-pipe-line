**minimal neural nets as plain functions** in **Python** and **JavaScript**:

---

## 1. Smallest “neural net”: linear model in Python

This is basically 1 neuron with no activation:
(\hat{y} = w x + b)

```python
# Tiny dataset: y = 2x + 1
xs = [1.0, 2.0, 3.0, 4.0]
ys = [3.0, 5.0, 7.0, 9.0]

# Parameters (weights)
w = 0.0
b = 0.0
lr = 0.01  # learning rate

def predict(x):
    return w * x + b

def train(epochs=1000):
    global w, b
    for _ in range(epochs):
        dw = 0.0
        db = 0.0
        for x, y in zip(xs, ys):
            y_hat = w * x + b
            error = y_hat - y
            # gradients for MSE loss
            dw += 2 * error * x
            db += 2 * error
        dw /= len(xs)
        db /= len(xs)

        w -= lr * dw
        b -= lr * db

    print("Trained params:", w, b)

train()
print("Prediction for x=5:", predict(5.0))
```

That’s already a (very small) neural network.

---

## 2. One hidden layer MLP in Python

Now: 2 inputs → 3 hidden units → 1 output with ReLU.

```python
import math
import random

# Simple dataset: OR logic
# (just as an example, treat it as regression or binary)
xs = [
    [0.0, 0.0],
    [0.0, 1.0],
    [1.0, 0.0],
    [1.0, 1.0],
]
ys = [0.0, 1.0, 1.0, 1.0]

# Helper
def relu(x):
    return x if x > 0 else 0

def relu_deriv(x):
    return 1.0 if x > 0 else 0.0

# Init weights
random.seed(42)
W1 = [[(random.random() - 0.5) for _ in range(2)] for _ in range(3)]  # 3x2
b1 = [(random.random() - 0.5) for _ in range(3)]                      # 3
W2 = [(random.random() - 0.5) for _ in range(3)]                      # 3
b2 = (random.random() - 0.5)
lr = 0.1

def forward(x):
    # hidden layer
    h_raw = []
    h = []
    for j in range(3):
        z = W1[j][0] * x[0] + W1[j][1] * x[1] + b1[j]
        h_raw.append(z)
        h.append(relu(z))
    # output (no activation)
    y_hat = W2[0] * h[0] + W2[1] * h[1] + W2[2] * h[2] + b2
    return h_raw, h, y_hat

def train(epochs=1000):
    global W1, b1, W2, b2
    for _ in range(epochs):
        # accumulate grads
        dW1 = [[0.0, 0.0] for _ in range(3)]
        db1 = [0.0, 0.0, 0.0]
        dW2 = [0.0, 0.0, 0.0]
        db2 = 0.0

        for x, y in zip(xs, ys):
            h_raw, h, y_hat = forward(x)
            error = y_hat - y

            # gradients for output layer
            dW2 = [dw + 2 * error * h_j for dw, h_j in zip(dW2, h)]
            db2 += 2 * error

            # backprop into hidden
            for j in range(3):
                dh = 2 * error * W2[j]
                dz = dh * relu_deriv(h_raw[j])
                dW1[j][0] += dz * x[0]
                dW1[j][1] += dz * x[1]
                db1[j] += dz

        n = len(xs)
        # average
        dW1 = [[v / n for v in row] for row in dW1]
        db1 = [v / n for v in db1]
        dW2 = [v / n for v in dW2]
        db2 /= n

        # update
        for j in range(3):
            W1[j][0] -= lr * dW1[j][0]
            W1[j][1] -= lr * dW1[j][1]
            b1[j]    -= lr * db1[j]
            W2[j]    -= lr * dW2[j]
        b2 -= lr * db2

train(epochs=2000)

for x in xs:
    _, _, y_hat = forward(x)
    print(x, "->", y_hat)
```

Everything is just functions and lists.

---

## 3. Same idea, but tiny JavaScript version (linear model)

Single-neuron linear model with gradient descent:

```js
// Tiny dataset: y = 2x + 1
const xs = [1, 2, 3, 4];
const ys = [3, 5, 7, 9];

let w = 0;
let b = 0;
const lr = 0.01;

function predict(x) {
  return w * x + b;
}

function train(epochs = 1000) {
  for (let e = 0; e < epochs; e++) {
    let dw = 0;
    let db = 0;

    for (let i = 0; i < xs.length; i++) {
      const x = xs[i];
      const y = ys[i];
      const y_hat = predict(x);
      const error = y_hat - y;

      dw += 2 * error * x;
      db += 2 * error;
    }

    dw /= xs.length;
    db /= xs.length;

    w -= lr * dw;
    b -= lr * db;
  }
  console.log("Trained params:", w, b);
}

train();
console.log("Prediction for x=5:", predict(5));
```

---

### How to grow this

1. **Play** with these tiny examples (change data, learning rate, epochs).
2. Then:

   * add a hidden layer in JS like the Python MLP.
   * or move to a framework (PyTorch / TensorFlow) once this feels obvious.

All of this scales up from the same pattern:
**arrays of numbers + simple functions + a training loop that nudges parameters.**
