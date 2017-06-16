function ecog_RenderGiftiLabels(g,vert_label,cmapInput,roiNames)
% function to render a gifti 
% 
% input:
%   g: gifti file with faces and vertices
%
% Viewing Angle: can be changed with ecog_ViewLight(90,0), changes both
% angle and light accordingly
%
% DH 2017

figure

if ischar(cmapInput)
    eval(['cmap =' cmapInput '(max(vert_label));']);
elseif isnumber(cmapInput)
    cmap = cmapInput;
end

% convert surface labels into colors for vertices in mesh (c)
c = 0.7+zeros(size(vert_label,1),3);

for k = 1:max(vert_label)
    c(vert_label==k,:)=repmat(cmap(k,:),length(find(vert_label==k)),1);
end

subplot(1,5,1:4)
tH = trimesh(g.faces, g.vertices(:,1), g.vertices(:,2), g.vertices(:,3), c); axis equal; hold on
set(tH, 'LineStyle', 'none', 'FaceColor', 'interp', 'FaceVertexCData',c)
l1 = light;
lighting gouraud
material([.3 .9 .2 50 1]); 
axis off
set(gcf,'Renderer', 'zbuffer')
view(270, 0);
set(l1,'Position',[-1 0 1])

subplot(1,5,5),hold on
for k = 1:length(roiNames)
    plot(1,k,'.','Color',cmap(k,:),'MarkerSize',30)
    text(1.03,k-.2,roiNames{k},'Color',cmap(k,:))
end
xlim([0.8 1.2]),ylim([0 length(roiNames)+1])
axis off

subplot(1,5,1:4)
