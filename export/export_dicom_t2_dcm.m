function export_dicom_t2_dcm(output_directory,dcm_files_path,m0map,t2map,tag,orientation)


% Create folders if not exist, and clear
folder_name = [output_directory,[filesep,'M0map-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);

folder_name = [output_directory,[filesep,'T2map-DICOM-',tag]];
if (~exist(folder_name, 'dir')); mkdir(folder_name); end
delete([folder_name,filesep,'*']);


% Flip and rotate in correct orientation
t2map = flip(permute(t2map,[1,3,2]),3);
m0map = flip(permute(m0map,[1,3,2]),3);


% Rotate the images if phase orienation == 1
number_of_images = size(t2map,1);
if orientation
    for i = 1:number_of_images
        t2mapr(i,:,:) = rot90(squeeze(t2map(i,:,:)),-1);
        m0mapr(i,:,:) = rot90(squeeze(m0map(i,:,:)),-1);
    end
    t2map = t2mapr;
    m0map = m0mapr;
end


% List of dicom file names
flist = dir(fullfile(dcm_files_path,'*.dcm'));
files = sort({flist.name});


% Generate new dicom headers
for i = 1:number_of_images
    
    % Read the Dicom header
    dcm_header(i) = dicominfo([dcm_files_path,filesep,files{i}]);
    
    % Changes some tags
    dcm_header(i).ImageType = 'DERIVED\RELAXATION\';
    dcm_header(i).InstitutionName = 'Amsterdam UMC';
    dcm_header(i).InstitutionAddress = 'Amsterdam, Netherlands';
    
end



% Export the T2 map Dicoms
for i=1:number_of_images
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'M0map-DICOM-',tag,filesep,'M0map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(m0map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end

% Export the M0 map Dicoms
for i=1:number_of_images
    fn = ['0000',num2str(i)];
    fn = fn(size(fn,2)-4:size(fn,2));
    fname = [output_directory,filesep,'T2map-DICOM-',tag,filesep,'T2map_',fn,'.dcm'];
    image = rot90(squeeze(cast(round(t2map(i,:,:)),'uint16')));
    dicomwrite(image, fname, dcm_header(i));
end




end