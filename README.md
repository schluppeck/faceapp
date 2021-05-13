# faceapp

denis schluppeck

2021-05-10 patched this together

>an example showing how to set up a wen API using the `Genie.jl`  framework in `julialang`

## Some construction notes

Quick summary of the steps I used to create this 

- make a julia environment (that records all the dependencies in `Project.toml` and `Manifest.toml`)
- use `Genie.jl` and add functionality to the `src/whatever_app_is_called.jl` file
- deploy with `heroku` (`docker`?, etc) using a buildpack (Dockerfile), etc.
- ping API from elsewhere (this deom returns `html` but can have `json` +/- base64 encoded images?

### Start up `julia`, make an env


```julia
] # to get package manager at REPL
generate faceapp
add MAT
add Genie
add Images
#...

# backspace to get back to julia
# edit code (using your favourite editor)


```


### Deploying to `heroku`

```bash
# get the nuildpack setup

HEROKU_APP_NAME=pca-app

heroku create $HEROKU_APP_NAME --buildpack https://github.com/Optomatica/heroku-buildpack-julia.git

# push the current repo to heroku remote
git push heroku master

# amd watch the build happen
# this will take a couple of minutes...
```

If the build + deploy is successful, then you'll see something like 

>remote:   ✓ Images
>remote:   115 dependencies successfully precompiled in 171 seconds


```bash
# then open in web browser
heroku open -a $HEROKU_APP_NAME
```

## Using API endpoints

In this demo, only a couple of endpoints are set up:

`/ ` -- serves a bit of HTML for info, linkds

`/im` -- serves and HTML page w. image included. Accepts one parameter `?caricature=some_float` that gets used in computation on `julia` side.

## refs

- **genie-buildpack** https://geniejl.readthedocs.io/en/latest/documentation/90--Deploying_With_Heroku_Buildpacks/

- **buildpack** https://github.com/Optomatica/heroku-buildpack-julia


## todo

- blog post to go along with this
- ideas for serving computed data to `pavlovia.org` experiments, etc





## References

- julialang
- Genie.jl
- heroku 
