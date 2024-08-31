# Groth16

This contains the implementation of the Groth16 and how one can generate proof and verify it using circom, snarkjs, and solidity smart contract.

## Let's get started

- Let's create a circuit first. Here we will take the same circuit we implemented in the [MiMC5](../MiMC5-Hashing-Circuit/circuit.circom) directory. Copy the code, and paste it in the newly created file `circuit.circom`.

- Now, let's generate the `r1cs` and `wasm` file for that circuit which will be used in the next steps. Thus, run the following command:

    ```bash
        circom circuit.circom --r1cs --wasm
    ```

- After that, we will be starting our ceremony with the help of `snarkjs`. Run this command:

    ```bash
        snarkjs powersoftau new bn128 12 ceremony_0000.ptau
    ```

- You will see a new file `ceremony_0000.ptau` created in your directory. Now, let's contribute randomness in that file:

    ```bash
        snarkjs powersoftau contribute ceremony_0000.ptau ceremony_0001.ptau
    ```

- A new file get created `ceremony_0001.ptau`. Delete the previous file i.e. `ceremony_0000.ptau` and let's repeat the previous step to contribute more randomness:

    ```bash
        snarkjs powersoftau contribute ceremony_0001.ptau ceremony_0002.ptau
    ```

- Delete the previous file i.e. `ceremony_0001.ptau` and now its time for phase2:

    ```bash
        snarkjs powersoftau prepare phase2 ceremony_0002.ptau ceremony_final.ptau -v
    ```

- Delete the previous file i.e. `ceremony_0002.ptau` and verify `ceremony_final.ptau` using the following command:

    ```bash
        snarkjs powersoftau verify ceremony_final.ptau
    ```

- Let's generate the `zkey` file for our circuit:

    ```bash
        snarkjs groth16 setup circuit.r1cs ceremony_final.ptau setup_0000.zkey
    ```

- Add some randomness to it:

    ```bash
        snarkjs zkey contribute setup_0000.zkey setup_final.zkey
    ```

- Let's verify our files again:

    ```bash
        snarkjs zkey verify circuit.r1cs ceremony_final.ptau setup_final.zkey
    ```

- Finally, lets generate the `proof.json` and `public.json` files:

    ```bash
        snarkjs groth16 fullprove input.json circuit_js/circuit.wasm setup_final.zkey proof.json public.json
    ```

- We can also create our solidity smart contract for this circuit which will help in verifying the proof on-chain:

    ```shell
        snarkjs zkey export solidityverifier setup_final.zkey verifier.sol
    ```

- Now lets generate the actual proof which can be passed to that smart contract:

    ```bash
        snarkjs zkey export soliditycalldata public.json proof.json
    ```
