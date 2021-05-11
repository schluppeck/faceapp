# faceapp

denis schluppeck

2021-05-10 patched this together

>an example showing how to set up a wen API using the `Genie.jl`  framework in `julialang`

## Start up `julia`, make an env

```julia


```


## Deploying to `heroku`

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



##

- **genie-buildpack** https://geniejl.readthedocs.io/en/latest/documentation/90--Deploying_With_Heroku_Buildpacks/

- **buildpack** https://github.com/Optomatica/heroku-buildpack-julia


## todo

- blog post to go along with this
- ideas for serving computed data to `pavlovia.org` experiments, etc





## References

- julialang
- Genie.jl
- heroku 
