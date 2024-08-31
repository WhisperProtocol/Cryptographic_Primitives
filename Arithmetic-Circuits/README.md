# Arithmetic-Circuits

This directory provides a general overview of how circuits are created and used to generate outputs using `circom` and `snarkjs`.

## Let's get started

- Start with a basic circuit, an equation - `x^2 * y + y^2 * x + 17`. Create a file named `circuit.circom` and add the following code:

    ```circom
        pragma circom 2.0.0;

        // f(x, y) = x^2 * y + x * y^2 + 17;

        template F() {
            signal input x;
            signal input y;
            signal output o;

            signal m1 <== x * x;
            signal m2 <== m1 * y;

            signal m3 <== y * y;
            signal m4 <== x * m3;

            o <== m2 + m4 + 17;
        }

        component main = F();
    ```

- Now let's generate wasm and r1cs files using `circom`:

    ```bash
        circom circuit.circom --r1cs --wasm
    ```

- We have to create an `input.json` file in order to provide the input values to the circuit. Add the following code to the `input.json` file:

    ```json
        {
            "x": 1,
            "y": 2
        }
    ```

- Now, generate the witness using the following command:

    ```bash
        node ./circuit_js/generate_witness.js ./circuit_js/circuit.wasm input.json witness.wtns
    ```

- Finally, let's generate the output file using `snarkjs`:

    ```bash
        snarkjs wtns export json witness.wtns output.json
    ```

- Remember this within any output file you generate:

    ```javascript
        [
            "1",
            "23", // Output of the circuit
            "1", // First input, x
            "2", // Second input, y
            "1", // Witness1
            "2", // Witness2
            "4" // Witness3
        ]
    ```

- **Note**: Number of witness depends upon the ciruit itself, in this case we have 3 witnesses.
