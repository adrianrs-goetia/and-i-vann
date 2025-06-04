const std = @import("std");
const rl = @import("raylib");
const math = std.math;
const random = std.Random;

const DISTANCE_BETWEEN_POINTS = 1.5;
const ATTEMPTS_PER_POINT = 30;
const CELL_SIZE: comptime_float = DISTANCE_BETWEEN_POINTS / math.sqrt2;
const GRID_SIZE = rl.Vector2{ .x = 100, .y = 100 };

const GridPoint = struct {
    x: i32,
    y: i32,
};
const GRID_X: comptime_int = @as(i32, @intFromFloat(math.ceil(GRID_SIZE.x / CELL_SIZE)));
const GRID_Y: comptime_int = @as(i32, @intFromFloat(math.ceil(GRID_SIZE.y / CELL_SIZE)));
const GRID = [GRID_X][GRID_Y]?GridPoint;

fn getGrid() GRID {
    var grid: GRID = undefined;
    for (0..GRID_X) |x| {
        for (0..GRID_Y) |y| {
            grid[x][y] = null;
        }
    }
    return grid;
}

const CellCoordinate = struct {
    x: i32,
    y: i32,
};

// fn getCellCoordinate(point: rl.Vector2, cellSize: f32) CellCoordinate {
//     return CellCoordinate{
//         .x = @intFromFloat(point.x / cellSize),
//         .y = @intFromFloat(point.y / cellSize),
//     };
// }

// fn isValid(point: rl.Vector2, grid: struct { x: i32, y: i32 }) bool {
//     const cellCoord = getCellCoordinate(point, CELL_SIZE);
//     for (math.Max(0, cellCoord.x - 2)..math.Min(grid.x, cellCoord.x + 3)) |i| {
//         for (math.Max(0, cellCoord.y - 2)..math.Min(grid.y, cellCoord.y + 3)) |j| {
//             // const neighbor = grid
//         }
//     }
// }

// fn poissonDiskSampling(grid: rl.Vector2, distanceBetweenEachPoint: f32, attemptsPerPoint: u8) std.ArrayList(rl.Vector2) {}

test "zigOptional" {
    var grid: GRID = getGrid();
    grid[4][2] = GridPoint{ .x = 0, .y = 9 };
    for (0..GRID_X) |x| {
        for (0..GRID_Y) |y| {
            const p = grid[x][y];
            if (x == 4 and y == 2) {
                try std.testing.expect(p != null);
            } else {
                try std.testing.expect(p == null);
            }
        }
    }
}
