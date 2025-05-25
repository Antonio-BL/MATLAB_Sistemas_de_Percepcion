function [area, perimetro, bboxes_mat, per2_area, centroidePonderado, firma, std_firma, num_regions] =...
    calcPropiedades(img, imgBin, imgEdge)

imgProps = regionprops(imgBin, "all");
num_regions = numel({imgProps.Area});


if num_regions >1
    [area, perimetro, per2_area, centroidePonderado, firma, std_firma, bboxes_mat] = ...
        calcPropiedadesMultiRegion(img, imgBin, imgEdge, imgProps);

else    % solo una region -------------------------------------------------
	
    perimetro = sum(imgEdge, "all");
    	if perimetro == 0 
	try 
	[ROWS, COLS] = size(imgEdge); 
	perimetro = ROWS*COLS - numel(imgEdge(imgEdge==0)); 
	catch exception
	perimetro  = sum(imgEdge,"all"); 
	end
	end
    area = sum(imgBin,"all");
    bboxes_mat = imgProps.BoundingBox;
    centroidePonderado = calculaCentroide(imgBin);
    per2_area = perimetro^2 / area;
    firma = calculaFirma(imgBin,centroidePonderado);
    std_firma = std(firma);
		

end
end
