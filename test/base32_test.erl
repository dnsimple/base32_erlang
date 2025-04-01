-module(base32_test).

-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").

std_cases() ->
    [
        {<<"">>, <<"">>},
        {<<"f">>, <<"MY======">>},
        {<<"fo">>, <<"MZXQ====">>},
        {<<"foo">>, <<"MZXW6===">>},
        {<<"foob">>, <<"MZXW6YQ=">>},
        {<<"fooba">>, <<"MZXW6YTB">>},
        {<<"foobar">>, <<"MZXW6YTBOI======">>}
    ].

lower_cases(Cases) ->
    [{I, <<<<(string:to_lower(C))>> || <<C>> <= O>>} || {I, O} <- Cases].

nopad_cases(Cases) ->
    [{I, <<<<C>> || <<C>> <= O, C =/= $=>>} || {I, O} <- Cases].

stringinput_cases(Cases) -> [{binary_to_list(I), O} || {I, O} <- Cases].

stringoutput_cases(Cases) -> [{I, binary_to_list(O)} || {I, O} <- Cases].

std_encode_test_() ->
    [?_assertEqual(Out, base32:encode(In)) || {In, Out} <- std_cases()].

std_decode_test_() ->
    [?_assertEqual(Out, base32:decode(In)) || {Out, In} <- std_cases()].

std_encode_lower_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [lower]))
     || {In, Out} <- lower_cases(std_cases())
    ].

std_decode_lower_test_() ->
    [?_assertEqual(Out, base32:decode(In)) || {Out, In} <- lower_cases(std_cases())].

std_encode_nopad_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [nopad]))
     || {In, Out} <- nopad_cases(std_cases())
    ].

std_encode_lower_nopad_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [lower, nopad]))
     || {In, Out} <- nopad_cases(lower_cases(std_cases()))
    ].

std_encode_string_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In))
     || {In, Out} <- stringinput_cases(std_cases())
    ].

std_decode_string_test_() ->
    [
        ?_assertEqual(Out, base32:decode(In))
     || {Out, In} <- stringoutput_cases(std_cases())
    ].

hex_cases() ->
    [
        {<<>>, <<>>},
        {<<"f">>, <<"CO======">>},
        {<<"fo">>, <<"CPNG====">>},
        {<<"foo">>, <<"CPNMU===">>},
        {<<"foob">>, <<"CPNMUOG=">>},
        {<<"fooba">>, <<"CPNMUOJ1">>},
        {<<"foobar">>, <<"CPNMUOJ1E8======">>}
    ].

hex_encode_test_() ->
    [?_assertEqual(Out, base32:encode(In, [hex])) || {In, Out} <- hex_cases()].

hex_decode_test_() ->
    [?_assertEqual(Out, base32:decode(In, [hex])) || {Out, In} <- hex_cases()].

hex_encode_lower_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [hex, lower]))
     || {In, Out} <- lower_cases(hex_cases())
    ].

hex_decode_lower_test_() ->
    [
        ?_assertEqual(Out, base32:decode(In, [hex]))
     || {Out, In} <- lower_cases(hex_cases())
    ].

hex_encode_nopad_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [hex, nopad]))
     || {In, Out} <- nopad_cases(hex_cases())
    ].

hex_encode_lower_nopad_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [hex, lower, nopad]))
     || {In, Out} <- nopad_cases(lower_cases(hex_cases()))
    ].

hex_encode_string_test_() ->
    [
        ?_assertEqual(Out, base32:encode(In, [hex]))
     || {In, Out} <- stringinput_cases(hex_cases())
    ].

hex_decode_string_test_() ->
    [
        ?_assertEqual(Out, base32:decode(In, [hex]))
     || {Out, In} <- stringoutput_cases(hex_cases())
    ].

decode_error_test_() ->
    [
        ?_assertError(non_alphabetic_character, base32:decode(<<55, 56, 57, 58>>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<55, 56, 57, 58>>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"AB/C">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"AB/C">>)),
        ?_assertError(incorrect_padding, base32:decode(<<"ABC===">>, [hex])),
        ?_assertError(incorrect_padding, base32:decode(<<"ABC===">>))
    ].

property_test_() ->
    [
        property(fun(B) -> B =:= base32:decode(base32:encode(B, [hex, nopad, lower]), [hex]) end),
        property(fun(B) -> B =:= base32:decode(base32:encode(B, [hex, nopad]), [hex]) end),
        property(fun(B) -> B =:= base32:decode(base32:encode(B, [hex]), [hex]) end),
        property(fun(B) -> B =:= base32:decode(base32:encode(B, [nopad, lower])) end),
        property(fun(B) -> B =:= base32:decode(base32:encode(B, [nopad])) end),
        property(fun(B) -> B =:= base32:decode(base32:encode(B)) end)
    ].

property(Fun) ->
    Opts = [
        quiet,
        long_result,
        {start_size, 1},
        {max_size, 1_000},
        {numtests, 100},
        {numworkers, erlang:system_info(schedulers_online)}
    ],
    ?_assert(
        proper:quickcheck(
            proper:conjunction([{encode_decode, ?FORALL(B, binary(), Fun(B))}]),
            Opts
        )
    ).
