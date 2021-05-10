using Genie
using Genie.Router
using Genie.Renderer.Html
using ImageIO, Images
using FileIO, ImageMagick, Base64

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        "Hi there!"
    end

    route("/im") do

        # make an image
        im = rand(RGB{N0f8}, 100, 100)

        buffer = Base.IOBuffer()
        ImageMagick.save(Stream(format"PNG", buffer), im)
        data = base64encode(take!(buffer))
        close(buffer)
        html("""
        <h1>a face</h1>
        <img src="data:image/png;base64,$(data)">
        """)
    end


    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))


