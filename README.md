# base32_erlang

![CI](https://github.com/dnsimple/base32_erlang/actions/workflows/ci.yml/badge.svg)

```
1> X = <<"foobar">>.
<<"foobar">>
2> X0 = base32:encode(X).
<<"MZXW6YTBOI======">>
3> X = base32:decode(X0).
<<"foobar">>
4> X1 = base32:encode(X, [hex]).
<<"CPNMUOJ1E8======">>
5> X = base32:decode(X1, [hex]).
<<"foobar">>
6> base32:encode(X, [lower]).
<<"mzxw6ytboi======">>
7> base32:encode(X, [nopad]).
<<"MZXW6YTBOI">>
8> base32:encode(X, [hex, lower, nopad]).
<<"cpnmuoj1e8">>
```
