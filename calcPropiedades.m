function [area, perimetro, bboxes_mat, per2_area, centroidePonderado, firma, std_firma, num_regions] =...
 calcPropiedades(img, imgBin, imgEdge, imgProps)

 num_regions = numel({imgProps.Area});
 

if num_regions >1
[area, perimetro, per2_area, centroidePonderado, firma, std_firma, bboxes_mat] = ...
calcPropiedadesMultiRegion(img, imgBin, imgEdge, imgProps); 

else    % solo una region -------------------------------------------------

    perimetro = sum(imgEdge, "all");
    area = sum(imgBin,"all");
    bboxes_mat = imgProps.BoundingBox; 
    centroidePonderado = calculaCentroide(imgBin);
    per2_area = perimetro^2 / area;
    firma = calculaFirma(imgBin,centroidePonderado);
    std_firma = std(firma);

end
end