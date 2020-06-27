module malvar_he_cutler_demosaic (
    input logic [7:0] pixel_matrix [0:4] [0:4],
    // Used to handle corners/edges of an image.
    // It is expected that the center pixel will always be present,
    // otherwise the behavior is undefined.
    input logic pixel_enable_matrix [0:4] [0:4],
    // 0 = Blue
    // 1 = Green in blue row (in BGGR, the first green)
    // 2 = Green in red row (in BGGR, the second green)
    // 3 = Red
    input logic [1:0] center_pixel_type,
    output logic [23:0] center_pixel_rgb
);

logic [11:0] estimate_of_green_at_non_green;
logic [3:0] estimate_of_green_at_non_green_counter;
always_comb
begin
    estimate_of_green_at_non_green = 12'd4 * 12'(pixel_matrix[2][2]);
    estimate_of_green_at_non_green_counter = 4'd4;

    if (pixel_enable_matrix[1][2])
    begin
        estimate_of_green_at_non_green += 12'd2 * 12'(pixel_matrix[1][2]);
        estimate_of_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[2][1])
    begin
        estimate_of_green_at_non_green += 12'd2 * 12'(pixel_matrix[2][1]);
        estimate_of_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[2][3])
    begin
        estimate_of_green_at_non_green += 12'd2 * 12'(pixel_matrix[2][3]);
        estimate_of_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[3][2])
    begin
        estimate_of_green_at_non_green += 12'd2 * 12'(pixel_matrix[3][2]);
        estimate_of_green_at_non_green_counter += 4'd2;
    end

    if (pixel_enable_matrix[0][2])
    begin
        estimate_of_green_at_non_green -= 12'(pixel_matrix[0][2]);
        estimate_of_green_at_non_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[2][0])
    begin
        estimate_of_green_at_non_green -= 12'(pixel_matrix[2][0]);
        estimate_of_green_at_non_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[2][4])
    begin
        estimate_of_green_at_non_green -= 12'(pixel_matrix[2][4]);
        estimate_of_green_at_non_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[4][2])
    begin
        estimate_of_green_at_non_green -= 12'(pixel_matrix[4][2]);
        estimate_of_green_at_non_green_counter -= 4'd1;
    end

    estimate_of_green_at_non_green /= estimate_of_green_at_non_green_counter;
end

logic [11:0] estimate_of_other_non_green_at_non_green;
logic [3:0] estimate_of_other_non_green_at_non_green_counter;
always_comb
begin
    estimate_of_other_non_green_at_non_green = 12'd6 * 12'(pixel_matrix[2][2]);
    estimate_of_other_non_green_at_non_green_counter = 4'd6;

    if (pixel_enable_matrix[1][1])
    begin
        estimate_of_other_non_green_at_non_green += 12'd2 * 12'(pixel_matrix[1][1]);
        estimate_of_other_non_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[1][3])
    begin
        estimate_of_other_non_green_at_non_green += 12'd2 * 12'(pixel_matrix[1][3]);
        estimate_of_other_non_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[3][3])
    begin
        estimate_of_other_non_green_at_non_green += 12'd2 * 12'(pixel_matrix[3][3]);
        estimate_of_other_non_green_at_non_green_counter += 4'd2;
    end
    if (pixel_enable_matrix[3][1])
    begin
        estimate_of_other_non_green_at_non_green += 12'd2 * 12'(pixel_matrix[3][1]);
        estimate_of_other_non_green_at_non_green_counter += 4'd2;
    end

    if (pixel_enable_matrix[0][2])
        estimate_of_other_non_green_at_non_green -= (12'd3 * 12'(pixel_matrix[0][2])) / 12'd2;
    if (pixel_enable_matrix[4][2])
        estimate_of_other_non_green_at_non_green -= (12'd3 * 12'(pixel_matrix[4][2])) / 12'd2;
    if (pixel_enable_matrix[2][0])
        estimate_of_other_non_green_at_non_green -= (12'd3 * 12'(pixel_matrix[2][0])) / 12'd2;
    if (pixel_enable_matrix[2][4])
        estimate_of_other_non_green_at_non_green -= (12'd3 * 12'(pixel_matrix[2][4])) / 12'd2;

    if (3'(pixel_enable_matrix[0][2]) + 3'(pixel_enable_matrix[4][2]) + 3'(pixel_enable_matrix[2][0]) + 3'(pixel_enable_matrix[2][4]) == 3'd4)
    begin
        estimate_of_other_non_green_at_non_green_counter -= 4'd6;
    end
    else if (3'(pixel_enable_matrix[0][2]) + 3'(pixel_enable_matrix[4][2]) + 3'(pixel_enable_matrix[2][0]) + 3'(pixel_enable_matrix[2][4]) == 3'd3)
    begin
        estimate_of_other_non_green_at_non_green_counter -= 4'd4; // TODO: 4.5 approximation
    end
    else if (3'(pixel_enable_matrix[0][2]) + 3'(pixel_enable_matrix[4][2]) + 3'(pixel_enable_matrix[2][0]) + 3'(pixel_enable_matrix[2][4]) == 3'd2)
    begin
        estimate_of_other_non_green_at_non_green_counter -= 4'd3;
    end
    else if (3'(pixel_enable_matrix[0][2]) + 3'(pixel_enable_matrix[4][2]) + 3'(pixel_enable_matrix[2][0]) + 3'(pixel_enable_matrix[2][4]) == 3'd1)
    begin
        estimate_of_other_non_green_at_non_green_counter -= 4'd1; // TODO: 1.5 approximation
    end

    estimate_of_other_non_green_at_non_green /= estimate_of_other_non_green_at_non_green_counter;
end

logic [11:0] estimate_of_non_green_in_same_row_as_green;
logic [3:0] estimate_of_non_green_in_same_row_as_green_counter;
always_comb
begin
    estimate_of_non_green_in_same_row_as_green = 12'd5 * 12'(pixel_matrix[2][2]);
    estimate_of_non_green_in_same_row_as_green_counter = 4'd5;
    
    if (pixel_enable_matrix[2][1])
    begin
        estimate_of_non_green_in_same_row_as_green += 12'd4 * 12'(pixel_matrix[2][1]);
        estimate_of_non_green_in_same_row_as_green_counter += 4'd4;
    end
    if (pixel_enable_matrix[2][3])
    begin
        estimate_of_non_green_in_same_row_as_green += 12'd4 * 12'(pixel_matrix[2][3]);
        estimate_of_non_green_in_same_row_as_green_counter += 4'd4;
    end

    if (pixel_enable_matrix[0][2])
        estimate_of_non_green_in_same_row_as_green += 12'(pixel_matrix[0][2]) / 12'd2;
    if (pixel_enable_matrix[4][2])
        estimate_of_non_green_in_same_row_as_green += 12'(pixel_matrix[4][2]) / 12'd2;
    
    if (pixel_enable_matrix[0][2] && pixel_enable_matrix[4][2])
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1; // TODO: approximate 0.5 when only 1 present

    if (pixel_enable_matrix[2][0])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[2][0]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[2][4])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[2][4]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end

    if (pixel_enable_matrix[1][1])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[1][1]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[1][3])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[1][3]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[3][3])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[3][3]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[3][1])
    begin
        estimate_of_non_green_in_same_row_as_green -= 12'(pixel_matrix[3][1]);
        estimate_of_non_green_in_same_row_as_green_counter -= 4'd1;
    end

    estimate_of_non_green_in_same_row_as_green /= estimate_of_non_green_in_same_row_as_green_counter;
end

logic [11:0] estimate_of_non_green_in_different_row_from_green;
logic [3:0] estimate_of_non_green_in_different_row_from_green_counter;
always_comb
begin
    estimate_of_non_green_in_different_row_from_green = 12'd5 * 12'(pixel_matrix[2][2]);
    estimate_of_non_green_in_different_row_from_green_counter = 4'd5;

    if (pixel_enable_matrix[1][2])
    begin
        estimate_of_non_green_in_different_row_from_green += 12'd4 * 12'(pixel_matrix[1][2]);
        estimate_of_non_green_in_different_row_from_green_counter += 4'd4;
    end
    if (pixel_enable_matrix[3][2])
    begin
        estimate_of_non_green_in_different_row_from_green += 12'd4 * 12'(pixel_matrix[3][2]);
        estimate_of_non_green_in_different_row_from_green_counter += 4'd4;
    end

    if (pixel_enable_matrix[2][0])
        estimate_of_non_green_in_different_row_from_green += 12'(pixel_matrix[2][0]) / 12'd2;
    if (pixel_enable_matrix[2][4])
        estimate_of_non_green_in_different_row_from_green += 12'(pixel_matrix[2][4]) / 12'd2;

    if (pixel_enable_matrix[2][0] && pixel_enable_matrix[2][4])
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1; // TODO: approximate 0.5 when only 1 present

    if (pixel_enable_matrix[0][2])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[0][2]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[4][2])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[4][2]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end

    if (pixel_enable_matrix[1][1])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[1][1]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[1][3])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[1][3]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[3][3])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[3][3]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end
    if (pixel_enable_matrix[3][1])
    begin
        estimate_of_non_green_in_different_row_from_green -= 12'(pixel_matrix[3][1]);
        estimate_of_non_green_in_different_row_from_green_counter -= 4'd1;
    end

    estimate_of_non_green_in_different_row_from_green /= estimate_of_non_green_in_different_row_from_green_counter;
end

always_comb
begin
    case (center_pixel_type)
        2'b11: // Red
        begin
            center_pixel_rgb[2] = pixel_matrix[2][2];
            center_pixel_rgb[1] = 8'(estimate_of_green_at_non_green);
            center_pixel_rgb[0] = 8'(estimate_of_other_non_green_at_non_green);
        end
        2'b10: // Green in red row
        begin
            center_pixel_rgb[2] = 8'(estimate_of_non_green_in_same_row_as_green);
            center_pixel_rgb[1] = pixel_matrix[2][2];
            center_pixel_rgb[0] = 8'(estimate_of_non_green_in_different_row_from_green);
        end
        2'b01: // Green in blue row
        begin
            center_pixel_rgb[2] = 8'(estimate_of_non_green_in_different_row_from_green);
            center_pixel_rgb[1] = pixel_matrix[2][2];
            center_pixel_rgb[0] = 8'(estimate_of_non_green_in_same_row_as_green);
        end
        2'b00: // Blue
        begin
            center_pixel_rgb[2] = 8'(estimate_of_other_non_green_at_non_green);
            center_pixel_rgb[1] = 8'(estimate_of_green_at_non_green);
            center_pixel_rgb[0] = pixel_matrix[2][2];
        end
    endcase
end

endmodule
