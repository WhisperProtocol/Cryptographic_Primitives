pragma circom 2.0.0;

include "./utils/montgomery.circom";

template generate_basis() {
    signal input x; // x coordinate of the point
    signal input y; // y coordinate of the point

    signal basis[51][2]; // 50 points (x and y coordinates) of the basis (generator) i.e. (2^5)^0, (2^5)^1, (2^5)^2, ..., (2^5)^49. Maybe last point is kept for storing some other value.
    signal basis2[51][2]; // All possible values that can appear due to the coefficients
    signal basis3[51][2];
    signal basis4[51][2];
    signal basis5[51][2];
    signal basis6[51][2];
    signal basis7[51][2];
    signal basis8[51][2];

    signal output oPoints[50][2]; // 50 points (x and y coordinates) of the basis in Montgomery form
    signal output o2Points[50][2];
    signal output o3Points[50][2];
    signal output o4Points[50][2];
    signal output o5Points[50][2];
    signal output o6Points[50][2];
    signal output o7Points[50][2];
    signal output o8Points[50][2];

    // Here we will be achieving 2^5 power on every part of the basis, i.e. for every point in the basis.
    component base2[50];
    component base4[50];
    component base8[50];
    component base16[50];
    component base32[50];

    component e2m = Edwards2Montgomery(); // Convert the base to montgomery
    e2m.in[0] <== x; // x coordinate of the point
    e2m.in[1] <== y; // y coordinate of the point

    // As first point is of power 0, we will keep it as it is.
    basis[0][0] <== e2m.out[0];
    basis[0][1] <== e2m.out[1];

    /*
        Explanation of what's going on here:
        - We are calculating all the variation of 4 bits of the basis, as each basis is divided into 4 bits, and the M we got here is 512 which provides us 3 Generators/basis of 200 bits each. Thus we got these details here:
        1. M -> The input value (512 bits)
        2. P -> Basis/Generator (200 bits) - thus M is divided into 3 basis/generators
        3. points -> each part of a basis is comprised of 4 bits, thus it gives us 50 parts/points in each basis

        - In this circuit, we will be provided generators/basis i.e. a point (x, y) and then using those x, and y coordinates we will be generating 800 values. why 800? let discuss that
        1. So, we have 50 points in each basis, that means 100 coordinates as each point has 2 coordinates (x, y)
        2. Now, we have also to calculate the variation of those points by alloting them coefficients, the coefficients values can vary from 1 to 8, thus we have 8 variations for each point we generate.
        3. Now, 8 * 100 = 800, thus we have 800 values to generate.

        A more depth:
        - We have various signals, basis[50], basis2[50], ...., and so on. Actually these will be acting as a way by which we can pass values and multiple them.
        - You also notice base2[50], base4[50], ..., and so on. These are the components that will be used to multiply the basis values with 2, 4, 8, 16, 32, and so on.
        - The reason why they are 32, because when dividing up the Generator/basis, each value is multiplied by increasing 2^5 which goes like, 2^5*0, 2^5*1, 2^5*2, ..., 2^5*49. Thus we have 50 values to generate.
        - In the first iteration of below 4 loop, our motive is to double up those powers to make it 2^5 which is 32.
        - and, then in the next iterations we are doubling up again to reach 2^49. Make sure that x, y coordinates goes with it as well, notice the lines 32-40.
        - In order to create basis2, basis3, etc... We used those values to multiply them with 2, 3, 4, 5, 6, 7, 8, and so on. Thus we have basis2, basis3, ..., and so on.
    */

    for (var i = 0; i < 50; i++) {
        base2[i] = MontgomeryDouble();
        base4[i] = MontgomeryDouble();
        base8[i] = MontgomeryDouble();
        base16[i] = MontgomeryDouble();
        base32[i] = MontgomeryDouble();

        base2[i].in[0] <== basis[i][0];
        base2[i].in[1] <== basis[i][1];

        base4[i].in[0] <== base2[i].out[0];
        base4[i].in[1] <== base2[i].out[1];
        // when coefficient could be 2
        basis2[i][0] <== base2[i].out[0];
        basis2[i][1] <== base2[i].out[1];

        base8[i].in[0] <== base4[i].out[0];
        base8[i].in[1] <== base4[i].out[1];
        // when coefficient could be 4
        basis4[i][0] <== base4[i].out[0];
        basis4[i][1] <== base4[i].out[1];

        base16[i].in[0] <== base8[i].out[0];
        base16[i].in[1] <== base8[i].out[1];
        // when coefficient could be 8
        basis8[i][0] <== base8[i].out[0];
        basis8[i][1] <== base8[i].out[1];

        base32[i].in[0] <== base16[i].out[0];
        base32[i].in[1] <== base16[i].out[1];

        basis[i + 1][0] <== base32[i].out[0];
        basis[i + 1][1] <== base32[i].out[1];
    }

    // when coefficient could be 3
    component adders3[50];
    for (var i3 = 0; i3 < 50; i3++){
        adders3[i3] = MontgomeryAdd();
        adders3[i3].in1[0] <== basis[i3][0];
        adders3[i3].in1[1] <== basis[i3][1];
        adders3[i3].in2[0] <== basis2[i3][0];
        adders3[i3].in2[1] <== basis2[i3][1];

        basis3[i3][0] <== adders3[i3].out[0];
        basis3[i3][1] <== adders3[i3].out[1];
    }

    // when coefficient could be 5
    component adders5[50];
    for (var i5 = 0; i5 < 50; i5++){
        adders5[i5] = MontgomeryAdd();
        adders5[i5].in1[0] <== basis[i5][0];
        adders5[i5].in1[1] <== basis[i5][1];
        adders5[i5].in2[0] <== basis4[i5][0];
        adders5[i5].in2[1] <== basis4[i5][1];

        basis5[i5][0] <== adders5[i5].out[0];
        basis5[i5][1] <== adders5[i5].out[1];
    }

    // when coefficient could be 6
    component adders6[50];
    for (var i6 = 0; i6 < 50; i6++){
        adders6[i6] = MontgomeryAdd();
        adders6[i6].in1[0] <== basis[i6][0];
        adders6[i6].in1[1] <== basis[i6][1];
        adders6[i6].in2[0] <== basis5[i6][0];
        adders6[i6].in2[1] <== basis5[i6][1];

        basis6[i6][0] <== adders6[i6].out[0];
        basis6[i6][1] <== adders6[i6].out[1];
    }

    // when coefficient could be 7
    component adders7[50];
    for (var i7 = 0; i7 < 50; i7++){
        adders7[i7] = MontgomeryAdd();
        adders7[i7].in1[0] <== basis[i7][0];
        adders7[i7].in1[1] <== basis[i7][1];
        adders7[i7].in2[0] <== basis6[i7][0];
        adders7[i7].in2[1] <== basis6[i7][1];

        basis7[i7][0] <== adders7[i7].out[0];
        basis7[i7][1] <== adders7[i7].out[1];
    }

    for (var j = 0; j < 50; j++) {
        oPoints[j][0] <== basis[j][0];
        oPoints[j][1] <== basis[j][1];

        o2Points[j][0] <== basis2[j][0];
        o2Points[j][1] <== basis2[j][1];

        o3Points[j][0] <== basis3[j][0];
        o3Points[j][1] <== basis3[j][1];

        o4Points[j][0] <== basis4[j][0];
        o4Points[j][1] <== basis4[j][1];

        o5Points[j][0] <== basis5[j][0];
        o5Points[j][1] <== basis5[j][1];

        o6Points[j][0] <== basis6[j][0];
        o6Points[j][1] <== basis6[j][1];

        o7Points[j][0] <== basis7[j][0];
        o7Points[j][1] <== basis7[j][1];

        o8Points[j][0] <== basis8[j][0];
        o8Points[j][1] <== basis8[j][1];
    }
}

component main = generate_basis();