# Convolutional-code

It's a matlab convolutional code without toolbox like poly2trellis or vitdec.
It can only use for systematic convolutional code with coderate = 1/2.

At Test.m, you can change the memory,D1,D2 for your own convolutional code.
D1 is the numerator of the feedback while D2 is the denominator. If D1 = 1 + D^2 + D^4, D1 will be [1 1 0 1].

Convolutional_code.m is same as Test.m but can use to simulate BER & FER.
