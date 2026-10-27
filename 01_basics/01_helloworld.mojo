# My first mojo program !
# Run:
# ------
# 1) pixi run mojo 01_helloworld.mojo
# 2) mojo 01_helloworld.mojo
#
# Build:
# ------
# 1) mojo build 01_helloworld.mojo
#    ./01_helloworld
from std import time

from gridv1 import Grid
from std.python import Python


def run_display(
    var grid: Grid,
    window_height: Int = 600,
    window_width: Int = 600,
    background_colour: String = "black",
    cell_colour: String = "green",
    pause: Float64 = 0.1,
) raises -> None:
    # import the pygame python package
    var pygame = Python.import_module("pygame")

    # initialize pygame modules
    pygame.init()

    # create a window and sets its title
    var window = pygame.display.set_mode(Python.tuple(window_height, window_width))
    pygame.display.set_caption("Conway's Game of life")

    var cell_height = window_height / grid.rows
    var cell_width = window_width / grid.cols
    var border_size = 1
    var cell_fill_colour = pygame.Color(cell_colour)
    var background_fill_colour = pygame.Color(background_colour)

    var running = True

    while running:
        # Poll for events
        var event = pygame.event.poll()
        if event.type == pygame.QUIT:
            # Quit if the window is closed
            running = False
        elif event.type == pygame.KEYDOWN:
            # Also quit if the user presses <Escape> or `q`
            if event.key == pygame.K_ESCAPE or event.key == pygame.K_q:
                running = False

        # Clear the window by painting with the background colour
        window.fill(background_fill_colour)

        for row in range(grid.rows):
            for col in range(grid.cols):
                if grid[row, col]:
                    var x = col * cell_width + border_size
                    var y = row * cell_height + border_size
                    var width = cell_width - border_size
                    var height = cell_height - border_size
                    pygame.draw.rect(
                        window,
                        cell_fill_colour,
                        Python.tuple(x, y, width, height),
                    )
        # Update the display,
        pygame.display.flip()
        # Pause to let me appreciate the scene
        time.sleep(pause)
        grid = grid.evolve()

    # Shutdown pygame cleanly
    pygame.quit()


def main() raises:
    var start = Grid.random(128, 128)
    run_display(start^)
