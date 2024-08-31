# MiMC5 Hashing Circuit

This repository contains the implementation of the MiMC5 hashing circuit and how can we generate the output using `circom` and `snarkjs`.

## Let's get started

- First, we have to install `ethers` to generate large numbers that act as constant within the `MiMC5` circuit. Install `ethers` using the following command:

    ```bash
        npm install ethers@5.7
    ```
  
- Then create file named `generate_big_number.js` and add the following code:

    ```javascript
        const { ethers } = require("ethers");

        const num = 10

        async function generate() {
            for (let i = 0; i < num; i++) {
                const n = ethers.BigNumber.from(ethers.utils.randomBytes(32))
                console.log(n.toString())
            }
        }

        generate()
            .catch((error) => {console.log(error); process.exit(1);});
    ```

- Run the script using the following command and copy down all those numbers generated:

    ```bash
        node generate_big_number.js
    ```

- Now, create a new file `circuit.circom` and add the following code:

    ```circom
        pragma circom 2.0.0;

        template MiMC5() {
            signal input x;
            signal input k;
            signal output h;

            var nRounds = 10;

            var c[nRounds] = [
                0,
                87765820752314405668794563432407248527122542182416579373545040637333985554790,
                67288788419990412737362757141295852156669591741710002455575355879912507112345,
                96790430082104970308654428550253890289894834328972294255922185255087719420403,
                86212030558592991947507099519158165802887521616045845589111841924263519141626,
                101649826801909768739577816505339162255360584323611909375505215036508490714525,
                62625149257810576711908033686391117005249375336714092903992538317928132909867,
                108111403341068377202435894648116601148799815666543527330126083767325296316910,
                28577656326214670091059677337584484970248128032135693467460325206571665722304,
                34961079435483828883666700549992100397845882789528280526822882237753533607250
            ];

            signal lastOutput[nRounds + 1];
            var base[nRounds];
            signal base2[nRounds];
            signal base4[nRounds];

            lastOutput[0] <== x;

            for (var i = 0; i < nRounds; i++) {
                base[i] = lastOutput[i] + k + c[i];
                base2[i] <== base[i] * base[i];
                base4[i] <== base2[i] * base2[i];

                lastOutput[i + 1] <== base4[i] * base[i];
            }

            h <== lastOutput[nRounds] + k;
        }

        component main = MiMC5(); 
    ```

- Let's generate wasm and r1cs files using `circom`:

    ```bash
        circom circuit.circom --r1cs --wasm
    ```

- We have to create an `input.json` file in order to provide the input values to the circuit. Add the following code to the `input.json` file or any values according to your wish:

    ```json
        {
            "x": "12343432435453465546543456546",
            "k": "12343432435453465546543456546"
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
