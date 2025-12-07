Documenting my journey to learning Mojo
==

**Note:** The examples here are working for Mojo's _stable_, as the examples
would use the community libraries/implementations. Also, these libraries are
built according to the _stable_ Mojo compiler.

Below is an example of the configuration `pixi.toml`

```pre
[workspace]
channels = [
  "https://conda.modular.com/max-nightly",
  "conda-forge",
  "https://repo.prefix.dev/modular-community",
]

[dependencies]
mojo = ">=0.26.1.0.dev2025120605,<0.27"
numpy = ">=2.3.5,<3"
emberjson = ">=0.2.1,<0.3"
```

Updating Pixi
==

The following is how you would update `pixi`, typically:

```
(mojo-journey) ➜  mojo-journey git:(main) pixi update 
Environment: default                                       
  ~ C ca-certificates  2025.10.5 hbd8a1cb_0            ->  2025.11.12 hbd8a1cb_0
  ~ C mblack           25.7.0.dev2025111005 release    ->  25.7.0.dev2025111305 release
  ~ C mojo             0.25.7.0.dev2025111005 release  ->  0.25.7.0.dev2025111305 release
  ~ C mojo-compiler    0.25.7.0.dev2025111005 release  ->  0.25.7.0.dev2025111305 release
  ~ C mojo-python      0.25.7.0.dev2025111005 release  ->  0.25.7.0.dev2025111305 release
  ~ C tk               8.6.13 h892fb3f_2               ->  8.6.13 h892fb3f_3
```

Running in Google Colab
==

Coming soon ...

(Hard) Clean up the Pixi Environment
==

To clean up your _local_ environment (e.g., workstation), you can perform the
following:

```bash
rm -fR .pixi # Removes everything 
pixi install # Installs everything in the `pixi.toml`
```

(Soft) Clean up the Pixi Environment
==

To clean up in a _soft_ fashion, simply edit the `pixi.toml` and change the
following:

```pre
* If you want to update the compiler, change the urls in the "channels" list.
* If you want to refresh the dependencies, remove the elements from the
"dependencies" list and add them manually via 'pixi add <X>'
```
