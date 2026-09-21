Vendored runtime-only subset of [ephread/inkgd](https://github.com/ephread/inkgd),
branch `godot4`, commit `fea9098ee18d6cdbe9a5e25f8f0296bcdf0fd96a`.

Includes `runtime/`, `ink_runtime.gd`, and the upstream MIT `LICENSE`.
The only upstream adjustment is removal of a trailing blank line at the end of
`runtime/lists/ink_list.gd`; runtime behavior is unchanged.
The editor plugin, Mono integration, examples, and tests are not needed here.
The runtime is registered as the `__InkRuntime` autoload in `project.godot`.
It supports Ink JSON versions 18–21, including this project's version 20.
