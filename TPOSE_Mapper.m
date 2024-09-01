%This program takes a .nc file and plots the geospatial data. 
%It takes a specific month (as specificied by the user, and plot the data
%across several depths.
% It then takes a specific depth (as specified by the user) and plots the data
%across the 12 months of a year
%% Set up
%User selects the file
[filename, pathname] = uigetfile('*.nc');
fullFileName = fullfile(pathname, filename);

%Gather Relevant Information
file_info = ncinfo(fullFileName);
Vars = {file_info.Variables.Attributes};
Info = {Vars{12}.Value};
load coastlines


%Extract the data
data = ncread(fullFileName,Info{1});
depth = ncread(fullFileName, "Z");
XC = ncread(fullFileName, "XC");
YC = ncread(fullFileName, "YC");

%Make plotting variable
plot_package.depth = depth;
plot_package.XC = XC;
plot_package.YC = YC;
plot_package.latlim = [min(YC),max(YC)];
plot_package.lonlim = [min(XC),max(XC)];
plot_package.coastlat = coastlat;
plot_package.coastlon = coastlon;
plot_package.Info = Info;
plot_package.year = extractBetween(filename,"_","_");

%Get User Input
setmonth = input('Please enter a month (Integer 1 to 12, Jan = 1, Feb = 2, etc.): ');
setdepth = input('Please enter a depth (-2.5 m to -5745 m, must be negative): ');
[~,setdepth] = min(abs(depth-setdepth));

%% Depth Loop 
for i = 1:9
    d = i+5*(i-1);
    plot_data = transpose(data(:,:,d,setmonth));
    plotter(plot_data, plot_package, d, setmonth)
end

%% Time Loop
for i = 1:12
    plot_data = transpose(data(:,:,setdepth,i));
    plotter(plot_data, plot_package, setdepth, i)
end

%% Subroutine to plot
function plotter(plot_data, plot_package, depth, month)
     
    figure()
    hold on
    %reference raster
    R = georefpostings(plot_package.latlim,plot_package.lonlim,[length(plot_package.YC),length(plot_package.XC)]);
    %set up map
    w = worldmap(plot_package.latlim,plot_package.lonlim); %Make world map
    plotm(plot_package.coastlat,plot_package.coastlon,"LineWidth",1,"Color","w"); %Add coastlines
    setm(w, 'MlabelParallel', 'south'); %Put labels at bottom

    geoshow(plot_data, R, "DisplayType", "surface");
    colorbar

    name = append(plot_package.Info{2}, " (", plot_package.Info{3}, ") at ", sprintf('%g',plot_package.depth(depth)), ...
        " meters during ", sprintf('%g',month), "/", plot_package.year{1});
    title(name)
end

