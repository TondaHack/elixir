-module(elixir_env).
-include("elixir.hrl").
-export([ex_to_env/1, env_to_scope/1, env_to_scope_with_vars/2, env_to_ex/1]).
-export([mergea/2, mergev/2, mergec/2, mergevc/2]).

%% Conversion in between #elixir_env, #elixir_scope and Macro.Env

env_to_ex({ Line, #elixir_env{} = Env }) ->
  erlang:setelement(1, Env#elixir_env{line=Line}, 'Elixir.Macro.Env').

ex_to_env(Env) when element(1, Env) == 'Elixir.Macro.Env' ->
  erlang:setelement(1, Env, elixir_env).

env_to_scope(#elixir_env{module=Module,file=File,function=Function,context=Context}) ->
  #elixir_scope{module=Module,file=File,function=Function,context=Context}.

env_to_scope_with_vars(#elixir_env{} = Env, Vars) ->
  (env_to_scope(Env))#elixir_scope{
    vars=orddict:from_list(Vars),
    counter=[{'_',length(Vars)}]
  }.

%% SCOPE MERGING

%% Receives two scopes and return a new scope based on the second
%% with their variables merged.

mergev(E1, E2) ->
  E2#elixir_env{
    vars=ordsets:union(E1#elixir_env.vars, E2#elixir_env.vars)
  }.

%% Receives two scopes and return the later scope
%% keeping the variables from the first (counters,
%% imports and everything else are passed forward).

mergea(E1, E2) ->
  E2#elixir_env{vars=E1#elixir_env.vars}.

%% Receives two scopes and return the first scope with
%% counters and flags from the later.

mergec(E1, _E2) ->
  E1.

%% Merges variables and counters, nothing lexical though.

mergevc(E1, E2) ->
  E2#elixir_env{
    vars=ordsets:union(E1#elixir_env.vars, E2#elixir_env.vars)
  }.
