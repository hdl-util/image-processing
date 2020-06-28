module malvar_he_cutler_demosaic_tb ();
    logic [7:0] pixel_matrix [0:4] [0:4] = '{default: 8'hAB};
    logic pixel_enable_matrix [0:4] [0:4] = '{default: 1'b1};
    logic [1:0] center_pixel_type;
    logic [23:0] center_pixel_rgb;
    malvar_he_cutler_demosaic malvar_he_cutler_demosaic(.pixel_matrix(pixel_matrix), .pixel_enable_matrix(pixel_enable_matrix), .center_pixel_type(center_pixel_type), .center_pixel_rgb(center_pixel_rgb));
    initial
    begin
        // Gray-preservation test:
        // If an area is gray, it should remain gray after demosaicing
        center_pixel_type = 2'b00;
        #1;
        assert (center_pixel_rgb == {8'hAB, 8'hAB, 8'hAB}) else $fatal(1, "Was %h", center_pixel_rgb);

        center_pixel_type = 2'b01;
        #1;
        assert (center_pixel_rgb == {8'hAB, 8'hAB, 8'hAB}) else $fatal(1, "Was %h", center_pixel_rgb);

        center_pixel_type = 2'b10;
        #1;
        assert (center_pixel_rgb == {8'hAB, 8'hAB, 8'hAB}) else $fatal(1, "Was %h", center_pixel_rgb);

        center_pixel_type = 2'b11;
        #1;
        assert (center_pixel_rgb == {8'hAB, 8'hAB, 8'hAB}) else $fatal(1, "Was %h", center_pixel_rgb);

        $finish;
    end
endmodule
