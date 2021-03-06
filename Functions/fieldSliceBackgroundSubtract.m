function [E_compiled, H_compiled, outu, outv, domainwidth, domaindepth, k_u, k_v] = fieldSliceBackgroundSubtract(Fields, Background_Fields, k_u, k_v, source_height_background, slice_axis, slice_location, even_interpolation, interpolation_gridsize, calculate, src_array)
Compiled_fields = cell(2,1);
Compiled_fields{1} = cell(3,1);
Compiled_fields{2} = cell(3,1);
        
for i = 1:2
    for component = Axis.elems
        if i == 1
            field = Fields{1};
            background_field = Background_Fields{1};
        elseif i == 2
            field = Fields{2};
            background_field = Background_Fields{2};
        else
            disp('Fix your loop indexing in FieldInterpolation_onbox')
            return
        end
        %fprintf('Working on %s\n', field{component}.name)
        primx = field{component}.grid3d.lall{1,1};
        primy = field{component}.grid3d.lall{2,1};
        primz = field{component}.grid3d.lall{3,1};
        dualx = field{component}.grid3d.lall{1,2};
        dualy = field{component}.grid3d.lall{2,2};
        dualz = field{component}.grid3d.lall{3,2};
        
        primx_background = background_field{component}.grid3d.lall{1,1};
        primy_background = background_field{component}.grid3d.lall{2,1};
        primz_background = background_field{component}.grid3d.lall{3,1};
        dualx_background = background_field{component}.grid3d.lall{1,2};
        dualy_background = background_field{component}.grid3d.lall{2,2};
        dualz_background = background_field{component}.grid3d.lall{3,2};
        
        switch field{component}.gt_array(Axis.x)
            case 'prim'
                tempX = primx;
            case 'dual'
                tempX = dualx;
        end
        switch field{component}.gt_array(Axis.y)
            case 'prim'
                tempY = primy;
            case 'dual'
                tempY = dualy;
        end
        switch field{component}.gt_array(Axis.z)
            case 'prim'
                tempZ = primz;
            case 'dual'
                tempZ = dualz;
        end
        
        switch background_field{component}.gt_array(Axis.x)
            case 'prim'
                tempX_background = primx_background;
            case 'dual'
                tempX_background = dualx_background;
        end
        switch background_field{component}.gt_array(Axis.y)
            case 'prim'
                tempY_background = primy_background;
            case 'dual'
                tempY_background = dualy_background;
        end
        switch background_field{component}.gt_array(Axis.z)
            case 'prim'
                tempZ_background = primz_background;
            case 'dual'
                tempZ_background = dualz_background;
        end
        
        
        
        min_x = min(min(primx)); max_x = max(max(primx));
        min_y = min(min(primy)); max_y = max(max(primy));
        min_z = min(min(primz)); max_z = max(max(primz));
        
        
        interpx_temp = sort(horzcat(primx,dualx));
        interpx = interpx_temp(interpx_temp >= min_x & interpx_temp <= max_x);
        interpy_temp = sort(horzcat(primy,dualy));
        interpy = interpy_temp(interpy_temp >= min_y & interpy_temp <= max_y);
        interpz_temp = sort(horzcat(primz,dualz));
        interpz = interpz_temp(interpz_temp >= min_z & interpz_temp <= max_z);
        
        
        
        
        
        domainwidth_background_initial = tempX_background(end) - tempX_background(1);
        domainwidth_initial = tempX(end) - tempX(1);
        domaindepth_initial = tempZ(end) - tempZ(1);
        
        
        if ((domainwidth_initial < 0.9*domainwidth_background_initial) || (domainwidth_initial > 1.1*domainwidth_background_initial))
            disp('Your background and main domain widths are probably different sizes, be sure to include matching domain files! If you are sure you have the right background file, comment out the return below this line!')
            return
        end
        
        
        field_values_temp_presubtraction = field{component}.array;
        field_values_temp_presubtraction(1,:,:) = field_values_temp_presubtraction(end,:,:);
        field_values_temp_presubtraction(end,:,:) = field_values_temp_presubtraction(1,:,:).*exp(-1i*k_u*domainwidth_initial);
        
        background_field_values_temp = background_field{component}.array;
        background_field_values_temp(1,:,:) = background_field_values_temp(end,:,:);
        background_field_values_temp(end,:,:) = background_field_values_temp(1,:,:).*exp(-1i*k_u*domainwidth_background_initial);
        
        %             tempX_clipped = tempX;
        %             tempX_clipped(tempX_clipped <= min_x) = [];
        %             tempX_clipped(tempX_clipped >= max_x) = [];
        %             if tempX_clipped(1) < tempX_clipped(end)
        %                 tempX_clipped = [min_x, tempX_clipped, max_x];
        %             else
        %                 tempX_clipped = [max_x, tempX_clipped, min_x];
        %             end
        
        
        %             tempY_clipped = tempY;
        %             tempY_clipped(tempY_clipped <= min_y) = [];
        %             tempY_clipped(tempY_clipped >= max_y) = [];
        %             if tempY_clipped(1) < tempY_clipped(end)
        %                 tempY_clipped = [min_y, tempY_clipped, max_y];
        %             else
        %                 tempY_clipped = [max_y, tempY_clipped, min_y];
        %             end
        
        %             tempZ_clipped = tempZ;
        %             tempZ_clipped(tempZ_clipped <= min_z) = [];
        %             tempZ_clipped(tempZ_clipped >= max_z) = [];
        %             if tempZ_clipped(1) < tempZ_clipped(end)
        %                 tempZ_clipped = [min_x, tempZ_clipped, max_x];
        %             else
        %                 tempZ_clipped = [max_x, tempZ_clipped, min_x];
        %             end
        
        
        domainwidth = abs(max_x - min_x);
        domaindepth = abs(max_z - min_z);
        
        [X_background, Y_background, Z_background] = ndgrid(tempX_background, tempY_background, tempZ_background);
        [X, Y, Z] = ndgrid(tempX, tempY, tempZ);
        
        [X_clipped, Y_clipped, Z_clipped] = ndgrid(interpx, interpy, interpz);
        
        
        try
            background_field_values = interpn(X_background, Y_background, Z_background, background_field_values_temp, X_clipped, Y_clipped, Z_clipped, 'linear');
        catch
            disp('Broke on background_field_values')
            i
            component
            save('testing_background_field_values.mat', '-v7.3')
            return
        end
        
        try
            field_values_temp_presubtraction_clipped = interpn(X, Y, Z, field_values_temp_presubtraction, X_clipped, Y_clipped, Z_clipped, 'linear');
        catch
            disp('Broke on field_values_temp clipping')
            i
            component
            save('testing_background_field_values.mat', '-v7.3')
            return
        end
        
        %% Subtract background
        %background_field_values_saved = background_field_values;
        background_field_values(Y_clipped < source_height_background) = 0;
        Y_saved = Y_clipped;
        switch calculate
            case 'backgroundSubtracted'
                field_values_temp = field_values_temp_presubtraction_clipped - background_field_values;
            case 'raw'
                field_values_temp = field_values_temp_presubtraction_clipped;
            case 'background'
                field_values_temp = background_field_values;
        end
        
        %save('bg_fieldsubtest.mat', 'field_values_temp', 'field_values_temp_presubtraction','background_field_values','source_height_background','domainwidth','domainwidth_background_initial', 'tempX_background', 'tempY_background', 'tempZ_background', 'tempX', 'tempY', 'tempZ', 'min_x', 'min_z', 'tempX_clipped', 'tempY_clipped', 'tempZ_clipped')
        
        
        
        
        %Janky, lazy solution to try for integration
        tempX = interpx;
        tempY = interpy;
        tempZ = interpz;
        
        
        interp = cell(1,3);
        known = cell(1,3);
        
        
        %Use permute to switch from Maxwell_FDFD to Matlab standard of Y,X,Z array
        %indices
        %field_values_temp = permute(field{1}{component}.array, [2 1 3]);
        
        % Should already be good here
        %             field_values_temp = field{component}.array;
        %             field_values_temp(1,:,:) = field_values_temp(end,:,:);
        %             field_values_temp(end,:,:) = field_values_temp(1,:,:).*exp(-1i*k_u*domainwidth);
        
        
        
        switch slice_axis
            case Axis.x
                k_u = k_v;
                if slice_location < min_x || slice_location > max_x
                    disp('Your slice_location is outside the range of simulation (Axis.x)')
                    return
                end
                if even_interpolation
                    interp{Axis.y} = linspace(min_y, max_y, round(abs((max_y-min_y)/interpolation_gridsize))+1);
                    interp{Axis.z} = linspace(min_z, max_z, round(abs((max_z-min_z)/interpolation_gridsize))+1);
                else
                    interp{Axis.y} = interpy;
                    interp{Axis.z} = interpz;
                end
                interp{Axis.x} = slice_location;
                [inarray, slice_index] = ismembertol(slice_location, tempX);
                
                if inarray % interp{Axis.x} = slice_location; known{Axis.x} = slice_location;
                    [~, Yq(:, :), Zq(:, :)] = ndgrid(interp{:});
                    [Yi, Zi] = ndgrid(tempY, tempZ);
                    Compiled_fields_temp(:,:) = field_values_temp(slice_index, :, :);
                else
                    known{Axis.y} = tempY;
                    known{Axis.z} = tempZ;
                    distance_away = sort(abs(slice_location - tempX));
                    if (distance_away(1) == distance_away(2))
                        vals = find(abs(slice_location - tempX) == distance_away(1));
                        slice_index(1) = vals(1);
                        slice_index(2) = vals(2);
                    else
                        slice_index(1) = find(abs(slice_location - tempX) == distance_away(1));
                        slice_index(2) = find(abs(slice_location - tempX) == distance_away(2));
                    end
                    slice_index = sort(slice_index);
                    known{Axis.x} = [tempX(slice_index(1)), tempX(slice_index(2))];
                    [~, Yq, Zq] = ndgrid(interp{:});
                    if length(size(Yq)) == 3
                        Yq = permute(Yq, [2 3 1]);
                        Zq = permute(Zq, [2 3 1]);
                    end
                    [Xi, Yi, Zi] = ndgrid([interp{Axis.x}, interp{Axis.x}], known{Axis.y}, known{Axis.z});
                    [X, Y, Z] = ndgrid(known{:});
                    field_values = field_values_temp(slice_index(1):slice_index(2), :, :);
                    Compiled_fields_temp = interpn(X, Y, Z, field_values, Xi, Yi, Zi, 'linear');
                    Compiled_fields_temp = permute(Compiled_fields_temp,[2 3 1]);
                    Compiled_fields_temp = Compiled_fields_temp(:,:,1);
                    if length(size(Yi)) == 3
                        Yi = permute(Yi(1,:,:), [2 3 1]);
                        Zi = permute(Zi(1,:,:), [2 3 1]);
                    end
                end
                Compiled_fields{i}{component} = interpn(Yi, Zi, Compiled_fields_temp, Yq, Zq, 'linear')';
                outu = Zq'; outv = Yq';
                
            case Axis.y
                slice_location_temp = src_array.intercept + slice_location;
                if slice_location_temp < min_y || slice_location_temp > max_y
                    disp('Your slice_location is outside the range of simulation (Axis.y)')
                    return
                end
                if even_interpolation
                    interp{Axis.x} = linspace(min_x, max_x, round(abs((max_x-min_x)/interpolation_gridsize))+1);
                    interp{Axis.z} = linspace(min_z, max_z, round(abs((max_z-min_z)/interpolation_gridsize))+1);
                else
                    interp{Axis.x} = interpx;
                    interp{Axis.z} = interpz;
                end
                interp{Axis.y} = src_array.intercept + slice_location;
                [inarray, slice_index] = ismembertol(slice_location_temp, tempY);
                if inarray %interp{Axis.y} = src_array.intercept + slice_location; known{Axis.y} = slice_location_temp;
                    [Xq(:,:), ~, Zq(:, :)] = ndgrid(interp{:});
                    [Xi, Zi] = ndgrid(tempX, tempZ);
                    Compiled_fields_temp(:,:) = field_values_temp(:, slice_index, :);
                else
                    known{Axis.x} = tempX;
                    known{Axis.z} = tempZ;
                    distance_away = sort(abs(slice_location_temp - tempY));
                    if (distance_away(1) == distance_away(2))
                        vals = find(abs(slice_location_temp - tempY) == distance_away(1));
                        slice_index(1) = vals(1);
                        slice_index(2) = vals(2);
                    else
                        slice_index(1) = find(abs(slice_location_temp - tempY) == distance_away(1));
                        slice_index(2) = find(abs(slice_location_temp - tempY) == distance_away(2));
                    end
                    slice_index = sort(slice_index);
                    known{Axis.y} = [tempY(slice_index(1)), tempY(slice_index(2))];
                    [Xq, ~, Zq] = ndgrid(interp{:});
                    if length(size(Xq)) == 3
                        Xq = permute(Xq, [1 3 2]);
                        Zq = permute(Zq, [1 3 2]);
                    end
                    [Xi, Yi, Zi] = ndgrid(known{Axis.x}, [interp{Axis.y}, interp{Axis.y}], known{Axis.z});
                    [X, Y, Z] = ndgrid(known{:});
                    field_values = field_values_temp(:, slice_index(1):slice_index(2), :);
                    Compiled_fields_temp = interpn(X, Y, Z, field_values, Xi, Yi, Zi, 'linear');
                    Compiled_fields_temp = permute(Compiled_fields_temp,[1 3 2]);
                    Compiled_fields_temp = Compiled_fields_temp(:,:,1);
                    if length(size(Xi)) == 3
                        Xi = permute(Xi(:, 1, :), [1 3 2]);
                        Zi = permute(Zi(:, 1, :), [1 3 2]);
                    end
                end
                Compiled_fields{i}{component} = interpn(Xi, Zi, Compiled_fields_temp, Xq, Zq, 'linear');
                outu = Xq; outv = Zq;
                
            case Axis.z
                if slice_location < min_z || slice_location > max_z
                    disp('Your slice_location is outside the range of simulation (Axis.z)')
                    return
                end
                if even_interpolation
                    interp{Axis.x} = linspace(min_x, max_x, round(abs((max_x-min_x)/interpolation_gridsize))+1);
                    interp{Axis.y} = linspace(min_y, max_y, round(abs((max_y-min_y)/interpolation_gridsize))+1);
                else
                    interp{Axis.x} = interpx;
                    interp{Axis.y} = interpy;
                end
                interp{Axis.z} = slice_location;
                [inarray, slice_index] = ismembertol(slice_location, tempZ);
                if inarray %interp{Axis.z} = slice_location; known{Axis.z} = slice_location;
                    [Xq(:, :), Yq(:, :), Zq(:, :)] = ndgrid(interp{:});
                    [Xi, Yi] = ndgrid(tempX, tempY);
                    Compiled_fields_temp(:,:) = field_values_temp(:, :, slice_index);
                else
                    known{Axis.x} = tempX;
                    known{Axis.y} = tempY;
                    distance_away = sort(abs(slice_location - tempZ));
                    if (distance_away(1) == distance_away(2))
                        vals = find(abs(slice_location - tempZ) == distance_away(1));
                        slice_index(1) = vals(1);
                        slice_index(2) = vals(2);
                    else
                        slice_index(1) = find(abs(slice_location - tempZ) == distance_away(1));
                        slice_index(2) = find(abs(slice_location - tempZ) == distance_away(2));
                    end
                    slice_index = sort(slice_index);
                    known{Axis.z} = [tempZ(slice_index(1)), tempZ(slice_index(2))];
                    [Xq(:,:), Yq(:,:), Zq(:,:)] = ndgrid(interp{:});
                    [Xi(:,:), Yi(:,:), Zi(:,:)] = ndgrid(known{Axis.x}, known{Axis.y}, interp{Axis.z});
                    [X, Y, Z] = ndgrid(known{:});
                    field_values = field_values_temp(:, :, slice_index(1):slice_index(2));
                    Compiled_fields_temp(:,:) = interpn(X, Y, Z, field_values, Xi, Yi, Zi, 'linear');
                end
                
                Compiled_fields{i}{component} = interpn(Xi, Yi, Compiled_fields_temp, Xq, Yq, 'linear');
                outu = Xq; outv = Yq;
        end
        
        %clear slice_location_temp vals slice_index inarray field_values field_values_temp Compiled_fields_temp X Y Z Xi Yi Zi Xq Yq Zq
    end
end


E_compiled = cat(3, Compiled_fields{1}{Axis.x}, Compiled_fields{1}{Axis.y}, Compiled_fields{1}{Axis.z});
H_compiled = cat(3, Compiled_fields{2}{Axis.x}, Compiled_fields{2}{Axis.y}, Compiled_fields{2}{Axis.z});
