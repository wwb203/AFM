%process contact mode image
%Img
experiment = topographyMiBin('vesicle.mi');
%ROI sorted by vescile
experiment = getVesicleList(experiment);
%assign a refPix to each vesicle
experiment = getRefPixList(experiment);
%main refPix, for deflSens
experiment = getMainRefPix(experiment);
save('experiment.mat','experiment');
