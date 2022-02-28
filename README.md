cuid
====

Collision-resistant ids optimized for horizontal scaling and sequential lookup performance,
written in Elixir.

For full rationale behind CUIDs refer to the [main project site](http://usecuid.org).


### Usage

Add Cuid as a dependency in your `mix.exs` file:

```elixir
defp deps do:
    [{:cuid, "~> 0.2.0"}]
end
```

Run `mix deps.get` to fetch and compile Cuid.

```elixir
Cuid.generate()  # => ch72gsb320000udocl363eofy

# or

state = Cuid.new()
Cuid.generate(state)  # => ch72gsb320000udocl363eofy
```

Each CUID is made by the following groups: `c - h72gsb32 - 0000 - udoc - l363eofy`

* `c` identifies this as a cuid, and allows you to use it in html entity ids. The fixed value helps keep the ids sequential.
* `h72gsb32` is a timestamp
* `0000` is a counter
* `udoc` is a fingerprint. The first two characters are based on the process ID and the next two are based on the hostname. This is the same method used in the [Node implementation](https://github.com/ericelliott/cuid/blob/master/src/node-fingerprint.js)
* `l363eofy` random (uses `:random.uniform`)

## Benchmarks

The benchmark script compares `Cuid.generate()` (new_global) to `Cuid.generate(state)` (new).

(old) here is the 0.1 version of Cuid, which used a single process to generate IDs.

```
$ mix run benchee/cuid.exs

##### With input new #####
Name               ips        average  deviation         median         99th %
generate      685.75 K        1.46 μs  ±2297.01%           1 μs           2 μs

##### With input new_global #####
Name               ips        average  deviation         median         99th %
generate      590.35 K        1.69 μs  ±2036.56%        1.02 μs        3.02 μs

##### With input old #####
Name               ips        average  deviation         median         99th %
generate      153.84 K        6.50 μs   ±285.56%        5.06 μs       18.18 μs
```

### Credit

* Lucas Duailibe
* Eric Elliott (author of [original JavaScript version](http://github.com/ericelliott/cuid))
* Paul Swartz
