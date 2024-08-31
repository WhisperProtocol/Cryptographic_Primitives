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