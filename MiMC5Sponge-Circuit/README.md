# MiMC5Sponge Circuit

This repository contains the implementation of the MiMC5Sponge circuit and how can we generate the output using `circom` and `snarkjs`.

## Let's get started

- First, we have to install `ethers` to generate large numbers that act as constant within the `MiMC5Sponge` circuit. Install `ethers` using the following command:

    ```bash
        npm install ethers@5.7
    ```

- Then create file named `generate_big_number.js` and add the following code:

    ```javascript
        const { ethers } = require("ethers");

        const num = 20

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

- Now, create a new file `mimc5sponge.circom` and add the following code:
