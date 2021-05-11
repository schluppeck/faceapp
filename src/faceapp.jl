# heroku version -> pca-app

using Genie
using Genie.Router
using Genie.Requests
using Genie.Renderer.Html
using ImageIO, Images
using FileIO, ImageMagick, Base64

using MAT
using LinearAlgebra
using ImageContrastAdjustment
using Interpolations

# load spaces
dataloc = "../data"

fspace = MAT.matread(dataloc * "/PCAModel_F.mat");

mspace = MAT.matread(dataloc * "/PCAModel_M.mat");

# some variance data to go along
mvariance = matread(dataloc * "/variance_M.mat");
m_sd = sqrt.(mvariance["variance"]); # standard deviation
fvariance = matread(dataloc * "/variance_F.mat");	
f_sd = sqrt.(fvariance["variance"]); # standard deviation

# "add the *variance/sd* to the dict"
mspace["sd"] = m_sd;
fspace["sd"] = f_sd;

caric = 1.5; # get from HTML??

# randomise first few components
a, b, c, d, e = rand(5)


mutable struct facedata
    coeffs::Vector{Float64}
    antiface::Bool
    dims::Tuple{Int64,Int64}
    caricature::Float64
end

facepoint = facedata([a, b, c, d, zeros(8)... ], false, (100,120), caric);

alg = Equalization(nbins = 256, minval=0.1, maxval=0.9)
#	"histogram eq for now... could do linear stretching"


"""
rgbinterp2(pic, U, V)

interpolate 3 channel, RGB image independently
re-written by ds 2021

-- original comments from UCL:

Rgb version of interp2- written when glyn got sick of typing 
this for the millionth time
""" 
function rgbinterp2(pic, U, V)

    # make interpolators
    itpR = interpolate(pic[:,:,1], BSpline(Linear()) )
    itpG = interpolate(pic[:,:,2], BSpline(Linear()) )
    itpB = interpolate(pic[:,:,3], BSpline(Linear()) )
    # itp(4,1.2)  # approximately A[2,6]
    # in matlab interp2 assumes 1:M, and 1:N grid if called like thiws
    # Vq = interp2(V,Xq,Yq) assumes X=1:N and Y=1:M where [M,N]=SIZE(V).
 
    #rec1 = cat(3, interp2(pic(:,:,1), U, V), interp2(pic(:,:,2), U, V), interp2(pic(:,:,3), U, V));
    
    rec = cat(itpR.(U,V), 
              itpG.(U,V),
              itpB.(U,V)    ; dims = 3 )
    
    return rec
end

# ╔═╡ 2dd6e36d-84d9-44fc-bf64-fb1d6675d853
function morphvec2image(X, imdims)
# % morphvec2image - reconstruct the image from morph vector
# % 
# % Peng Li revised 24-05-2010
# to julia - denis schluppeck, 2021
        
    #Split face vector into pixel position and texture components
    npix = prod(imdims)
    Px = reshape(X[ 1:npix ], reverse(imdims) );
    Py = reshape(X[ (1+npix):(2*npix) ], reverse(imdims));

    # % Amended lines added by HG 16/07/10, see original function morphvec2data.m
    # % Px = reshape(X(1:w*h), h, w)+1;
    # % Py = reshape(X(1+w*h : 2*w*h), h, w)+1;
    
    tex = reshape(X[ (1+2*npix) : end], (reverse(imdims)..., 3));
    
    #% Correct impossible pixel position values
    Px[Px .< 1] .= 1; 
    Px[Px .> imdims[1] ] .= imdims[1]; # width - should be 100 here
    Py[Py .< 1] .= 1; 
    Py[Py .> imdims[2] ] .= imdims[2];
                
    #% Replace negative RGB values with zero
    tex[tex .< 0] .= 0;
    tex[tex .> 255] .= 255;
    # figure out filtering an dscaling... 
    
    # Interpolate faces from texture and shape
    Y = rgbinterp2(tex, Py, Px);
                
    # Replace negative RGB values with zero
    Y[Y .< 0] .= 0;
    Y[Y .> 255] .= 255;
    
    # then scale...
    Y = Y ./ 255;  # % Rescale to 0-1 to store

    return Y
end

# ╔═╡ 34d28be2-6300-459c-b7e7-f83f457c4cea
"""
minimalGenFace(data, space)

given a facedata struct and a PCA space, return an image

    Q, antiface, space, variance, imdims, multiplier)
          returns     IM - image

    but also    IMS - sharpened image
                IM_inv - inverse
                IMS_inv - inverse / sharpened. 

    # orig code: % Created by HG 18/02/11 -- UCL
    # ds 2019-12-11, derived from UCL code, tidied
"""
function minimalGenFace(data, space)
    
            
    # Q = column vector of PC coefficients (loadings) of face to be recovered
    Q = data.coeffs # force column vec
    
    #% Create sharpening filter
    #fil = fspecial('unsharp');
    
    #% multiplier = silly; %this sets the caricaturing coeff.
    
    #%Turn slider coeff into PCA coeffs
    Q = 2 .* Q .- 1; # mean 0
    Q = space["sd"] .* Q;
    
    # caricature
    Q = Q .* data.caricature;
    
    #% (6) Calculate relative morph vector of target identity by
    #% multiplying coefficient by PCs
    
    QRC = space["PCA"] * Q;
            
    
    # % (7) Calculate the morph vector of target identity by adding
    # % target mean
    R = space["MorphMean"] .+ QRC;
            
            
    # % (7a) Calculate (7) Calculate the anti-morph vector of target
    # % identity by subtracting mean-relative vector from target mean
    R_inv = space["MorphMean"] .- QRC;
            
            
    # % (8) Transform R_ifj to image format
    imdims = data.dims
    IM = morphvec2image(R, imdims);
    # IM_inv = morphvec2image(R_inv, data.dims);
            
    # % (9) Sharpen image
    # IMS = imfilter(IM,fil, 'replicate');
    # IMS_inv = imfilter(IM_inv,fil, 'replicate');
    
            
    # % 'replicate' 	Input array values outside the bounds of the array
    # % are assumed to equal the nearest array border value. Used to try
    # % to to prevent the pale border appearing on final images.
    # % @DS . not sure about above comment here..
            
end 

# ╔═╡ 516dbf75-9a7f-4542-b371-75098af4231f
imF = minimalGenFace(facepoint, fspace);

# ╔═╡ bc15fe71-26f8-47d0-a0ae-c566cc13a356
img_adjusted = 
	adjust_histogram(imF, alg);


function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        html("""
        <h1>minimal face app</h1>
        <p>testing some basic API calls at /im route</p>
        <ul>
            <li><a href="/im">/im  the basic image</a></li>
            <li><a href="/im?caricature=1.5">/im?caricature=1.5</a></li>
            <li><a href="/im?caricature=-1.8">/im?caricature=-1.8</a></li>
        </ul>
        <p>you can also try editing the URL, as per REST API ... <br>
            <code>?caricature=1.2</code>, where you can replace the value 1.2 with your choice. </p>
       
        """)
    end

    route("/im") do

        caricature = parse(Float64, getpayload(:caricature, "1.0"))

        a, b, c, d = rand(4)

        facepoint = facedata([a, b, c, d, zeros(8)... ], false, (100,120), caricature);


        imF = minimalGenFace(facepoint, fspace);

        # ╔═╡ bc15fe71-26f8-47d0-a0ae-c566cc13a356
        img_adjusted = 
	        adjust_histogram(imF, alg);

        im = colorview(RGB,permuteddimsview(img_adjusted, (3,1,2)))


        buffer = Base.IOBuffer()
        ImageMagick.save(Stream(format"PNG", buffer), im)
        data = base64encode(take!(buffer))
        close(buffer)
        html("""
        <center>
        <h1>a face</h1> 
        <p> params[1..4] (random): $(round.([a, b, c, d]; digits=3))
        </p>
        <p> caricature: $(round.(caricature; digits=3))
        </p>
        
        <img src="data:image/png;base64,$(data)" width="30%">
        <br>

        <a href="/">go back to main page</a>

        </center>
   
        """)
    end


    Genie.AppServer.startup()
end

if isempty(ARGS)
    launchServer(3000)
else
    launchServer(parse(Int, ARGS[1]))
end


