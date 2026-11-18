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

%% Where a character outside the alphabet stands decides which code reaches it: the groups before
%% the last, the last group when it ends in padding, its shifted last character, or the last group
%% of an input without padding.
decode_error_position_test_() ->
    [
        ?_assertError(non_alphabetic_character, base32:decode(<<"MZXW6Y!BOI======">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CPNMUO!1E8======">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"MZXW6YTBO!======">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CPNMUOJ1E!======">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"M/======">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"C/======">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"MZXW6YTBMZXW6YT/">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CPNMUOJ1CPNMUOJ/">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"MY======MZXW6YTB">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CO======CPNMUOJ1">>, [hex])),
        ?_assertError(non_alphabetic_character, base32:decode(<<"MZXW6YT", 200>>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CPNMUOJ", 200>>, [hex])),
        ?_assertError(incorrect_padding, base32:decode(<<"MZXW6YTB=">>)),
        ?_assertError(incorrect_padding, base32:decode(<<"CPNMUOJ1=">>, [hex]))
    ].

%% A tail that no padding explains raises incorrect_padding, unless a character before it is
%% outside the alphabet
decode_error_precedence_test_() ->
    [
        ?_assertError(non_alphabetic_character, base32:decode(<<"MZ!W6YTBMZX">>)),
        ?_assertError(non_alphabetic_character, base32:decode(<<"CP!MUOJ1CPN">>, [hex])),
        ?_assertError(incorrect_padding, base32:decode(<<"MZXW6YTBM!X">>)),
        ?_assertError(incorrect_padding, base32:decode(<<"CPNMUOJ1C!N">>, [hex]))
    ].

%% Options other than atoms, and atoms other than the ones the function reads, mean what they
%% mean to proplists:get_bool/2
option_test_() ->
    [
        ?_assertEqual(<<"CPNMUOJ1E8======">>, base32:encode(<<"foobar">>, [{hex, true}])),
        ?_assertEqual(<<"MZXW6YTBOI======">>, base32:encode(<<"foobar">>, [{hex, false}, hex])),
        ?_assertEqual(<<"cpnmuoj1e8">>, base32:encode(<<"foobar">>, [{nopad, true}, lower, hex])),
        ?_assertEqual(<<"MZXW6YTBOI======">>, base32:encode(<<"foobar">>, [foo])),
        ?_assertEqual(<<"mzxw6ytboi======">>, base32:encode(<<"foobar">>, [{lower, true}])),
        ?_assertEqual(<<"MZXW6YTBOI======">>, base32:encode(<<"foobar">>, [{lower, false}, lower])),
        ?_assertEqual(<<"MZXW6YTBOI======">>, base32:encode(<<"foobar">>, [{nopad, false}, nopad])),
        ?_assertEqual(<<"CPNMUOJ1E8======">>, base32:encode(<<"foobar">>, [hex, {hex, false}])),
        ?_assertEqual(<<"CPNMUOJ1E8======">>, base32:encode(<<"foobar">>, [{foo, bar}, hex])),
        ?_assertEqual(<<"MZXW6YTBOI======">>, base32:encode(<<"foobar">>, [{hex}, hex])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"CPNMUOJ1E8======">>, [{foo, bar}, hex])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"MZXW6YTBOI======">>, [{hex, true, x}, hex])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"CPNMUOJ1E8======">>, [{hex, true}])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"CPNMUOJ1E8======">>, [nopad, lower, hex])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"MZXW6YTBOI======">>, [{hex, false}, hex])),
        ?_assertEqual(<<"foobar">>, base32:decode(<<"MZXW6YTBOI======">>, [nopad])),
        ?_assertError(function_clause, base32:encode(<<"foobar">>, hex)),
        ?_assertError(function_clause, base32:decode(<<"CPNMUOJ1E8======">>, hex))
    ].

%% Every number of whole groups of 8 characters, 5 octets, up to the 12 that decode without
%% appending and past them, each with every tail, and so every size that encodes in one
%% construction, through the tail, or in the loop
group_count_test_() ->
    Opts = [{[], []}, {[nopad], []}, {[lower], []}, {[hex], [hex]}, {[hex, nopad, lower], [hex]}],
    [
        ?_assertEqual(
            [B || _ <- Opts],
            [base32:decode(base32:encode(B, Encode), Decode) || {Encode, Decode} <- Opts]
        )
     || Groups <- lists:seq(0, 14),
        Tail <- [<<>>, <<"f">>, <<"fo">>, <<"foo">>, <<"foob">>],
        B <- [<<(binary:copy(<<"fooba">>, Groups))/binary, Tail/binary>>]
    ].

%% Any one octet of an encoding replaced by any other: the result decodes, or raises one of the
%% two errors decode/2 documents, never anything else
corrupt_property_test_() ->
    [
        corrupt_property([], []),
        corrupt_property([nopad, lower], []),
        corrupt_property([hex], [hex]),
        corrupt_property([hex, nopad, lower], [hex])
    ].

corrupt_property(EncodeOpts, DecodeOpts) ->
    Opts = [
        quiet,
        long_result,
        {start_size, 1},
        {max_size, 1_000},
        {numtests, 500},
        {numworkers, erlang:system_info(schedulers_online)}
    ],
    Prop = ?FORALL(
        {B, Pos, Octet},
        {non_empty(binary()), non_neg_integer(), byte()},
        begin
            Text = base32:encode(B, EncodeOpts),
            At = Pos rem byte_size(Text),
            <<Head:At/binary, _, Tail/binary>> = Text,
            try base32:decode(<<Head/binary, Octet, Tail/binary>>, DecodeOpts) of
                Decoded -> is_binary(Decoded)
            catch
                error:non_alphabetic_character -> true;
                error:incorrect_padding -> true
            end
        end
    ),
    ?_assert(proper:quickcheck(Prop, Opts)).

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
