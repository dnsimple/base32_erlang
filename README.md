# base32_erlang

[![Build Status](https://github.com/dnsimple/base32_erlang/actions/workflows/ci.yml/badge.svg)](https://github.com/dnsimple/base32_erlang/actions/workflows/ci.yml)
[![Module Version](https://img.shields.io/hexpm/v/base32.svg)](https://hex.pm/packages/base32)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/base32/)
[![Hex Downloads](https://img.shields.io/hexpm/dt/base32.svg?maxAge=2592000)](https://hex.pm/packages/base32)
[![Coverage Status](https://coveralls.io/repos/github/dnsimple/base32_erlang/badge.svg?branch=main)](https://coveralls.io/github/dnsimple/base32_erlang?branch=main)

```erlang
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
