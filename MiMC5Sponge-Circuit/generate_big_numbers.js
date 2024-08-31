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