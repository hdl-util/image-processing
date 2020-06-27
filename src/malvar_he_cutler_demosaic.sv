module malvar_he_cutler_demosaic (
    input logic [7:0] pixel_mosaic_matrix [0:5] [0:5],
    // 0 = Blue
    // 1 = Green in blue row (in BGGR, the first green)
    // 2 = Green in red row (in BGGR, the second green)
    // 3 = Red
    input logic [1:0] center_pixel_type,
    output logic [23:0] center_pixel_rgb
);

logic [11:0] green_estimate_at_non_green;
always_comb
begin
    green_estimate_at_non_green = 12'd4 * 12'(pixel_mosaic_matrix[2][2]);

    green_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[1][2]);
    green_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[2][1]);
    green_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[2][3]);
    green_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[3][2]);

    green_estimate_at_non_green -= 12'(pixel_mosaic_matrix[0][2]);
    green_estimate_at_non_green -= 12'(pixel_mosaic_matrix[2][0]);
    green_estimate_at_non_green -= 12'(pixel_mosaic_matrix[2][4]);
    green_estimate_at_non_green -= 12'(pixel_mosaic_matrix[4][2]);

    green_estimate_at_non_green /= 12'd8;
end

logic [11:0] other_estimate_at_non_green;
always_comb
begin
    other_estimate_at_non_green = 12'd6 * 12'(pixel_mosaic_matrix[2][2]);

    other_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[1][1]);
    other_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[1][3]);
    other_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[3][3]);
    other_estimate_at_non_green += 12'd2 * 12'(pixel_mosaic_matrix[3][1]);

    other_estimate_at_non_green -= (12'd3 * 12'(pixel_mosaic_matrix[0][2])) / 12'd2;
    other_estimate_at_non_green -= (12'd3 * 12'(pixel_mosaic_matrix[4][2])) / 12'd2;
    other_estimate_at_non_green -= (12'd3 * 12'(pixel_mosaic_matrix[2][0])) / 12'd2;
    other_estimate_at_non_green -= (12'd3 * 12'(pixel_mosaic_matrix[2][4])) / 12'd2;

    other_estimate_at_non_green /= 12'd8;
end

logic [11:0] non_green_estimate_in_same_row_at_green;
always_comb
begin
    non_green_estimate_in_same_row_at_green = 12'd5 * 12'(pixel_mosaic_matrix[2][2]);
    
    non_green_estimate_in_same_row_at_green += 12'd4 * 12'(pixel_mosaic_matrix[2][1]);
    non_green_estimate_in_same_row_at_green += 12'd4 * 12'(pixel_mosaic_matrix[2][3]);

    non_green_estimate_in_same_row_at_green += 12'(pixel_mosaic_matrix[0][2]) / 12'd2;
    non_green_estimate_in_same_row_at_green += 12'(pixel_mosaic_matrix[4][2]) / 12'd2;

    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[2][0]);
    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[2][4]);

    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[1][1]);
    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[1][3]);
    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[3][3]);
    non_green_estimate_in_same_row_at_green -= 12'(pixel_mosaic_matrix[3][1]);

    non_green_estimate_in_same_row_at_green /= 12'd8;
end

logic [11:0] non_green_estimate_in_different_row_at_green;
always_comb
begin
    non_green_estimate_in_different_row_at_green = 12'd5 * 12'(pixel_mosaic_matrix[2][2]);
    
    non_green_estimate_in_different_row_at_green += 12'd4 * 12'(pixel_mosaic_matrix[1][2]);
    non_green_estimate_in_different_row_at_green += 12'd4 * 12'(pixel_mosaic_matrix[3][2]);

    non_green_estimate_in_different_row_at_green += 12'(pixel_mosaic_matrix[2][0]) / 12'd2;
    non_green_estimate_in_different_row_at_green += 12'(pixel_mosaic_matrix[2][4]) / 12'd2;

    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[0][2]);
    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[4][2]);

    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[1][1]);
    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[1][3]);
    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[3][3]);
    non_green_estimate_in_different_row_at_green -= 12'(pixel_mosaic_matrix[3][1]);

    non_green_estimate_in_different_row_at_green /= 12'd8;
end

always_comb
begin
    case (center_pixel_type)
        2'b11: // Red
        begin
            center_pixel_rgb[2] = pixel_mosaic_matrix[2][2];
            center_pixel_rgb[1] = 8'(green_estimate_at_non_green);
            center_pixel_rgb[0] = 8'(other_estimate_at_non_green);
        end
        2'b10: // Green in red row
        begin
            center_pixel_rgb[2] = 8'(non_green_estimate_in_same_row_at_green);
            center_pixel_rgb[1] = pixel_mosaic_matrix[2][2];
            center_pixel_rgb[0] = 8'(non_green_estimate_in_different_row_at_green);
        end
        2'b01: // Green in blue row
        begin
            center_pixel_rgb[2] = 8'(non_green_estimate_in_different_row_at_green);
            center_pixel_rgb[1] = pixel_mosaic_matrix[2][2];
            center_pixel_rgb[0] = 8'(non_green_estimate_in_same_row_at_green);
        end
        2'b00: // Blue
        begin
            center_pixel_rgb[2] = 8'(other_estimate_at_non_green);
            center_pixel_rgb[1] = 8'(green_estimate_at_non_green);
            center_pixel_rgb[0] = pixel_mosaic_matrix[2][2];
        end
    endcase
end

endmodule
