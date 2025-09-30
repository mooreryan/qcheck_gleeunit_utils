% This module provides a modified `run_eunit` function that doesn't specify
% a timeout.
%
% Based on gleeunit commit 28993019b465e0d5872d67a890b3ec5ba7e42283


% Original copyright notice:
%
%
% Copyright 2021, Louis Pilfold <louis@lpil.uk>.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.


-module(qcheck_gleeunit_utils_ffi).

-export([find_files/2, run_eunit/2]).

find_files(Pattern, In) ->
  Results = filelib:wildcard(binary_to_list(Pattern), binary_to_list(In)),
  lists:map(fun list_to_binary/1, Results).

run_eunit(Tests, Options) ->
    case eunit:test(Tests, Options) of
        ok -> {ok, nil};
        error -> {error, nil};
        {error, Term} -> {error, Term}
    end.
