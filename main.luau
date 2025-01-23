local HitboxExpanderConfiguration: {Limb: string, Size: number, Shape: Enum.PartType, Color: Color3, Material: Enum.Material, MaterialVariant: string, Transparency: number, Reflectance: number, CastShadow: boolean, EnableFluidForces: boolean, CanCollide: boolean, CanTouch: boolean, CanQuery: boolean, Locked: boolean, CustomPhysicalProperties: PhysicalProperties, Massless: boolean, RootPriority: number, Fixes: boolean} = {
	-- Basic
	Limb = {"Torso", "UpperTorso"}, -- "All": expands every limb no matter their name, except the Root.
	Size = 15,

	-- Customization
	Shape = Enum.PartType.Ball,
	Color = Color3.fromRGB(255, 0, 0),
	Material = Enum.Material.ForceField,
	MaterialVariant = "",
	Transparency = 0,
	Reflectance = 0,
	CastShadow = false,

	-- Advanced
	EnableFluidForces = false,
	CanCollide = false,
	CanTouch = true,
	CanQuery = true,
	Locked = false,
	CustomPhysicalProperties = PhysicalProperties.new(0.001, 0, 0, 0, 0),
	Massless = true,
	RootPriority = math.huge,

	-- Experimental
	Fixes = true, -- Removes particles, decals, textures, smoothens textures, etc.
	HumanoidTagRemover = true, -- Removes the annoying vision blocking humanoid tag.
	KillAll = false, -- Teleports hitboxes to your mouse's hit CFrame. OP in games like Arsenal.
};

-- // Variables

local Players: Players = game:GetService("Players");
local LocalPlayer: Player = Players.LocalPlayer;

-- // Functions

if (_G.LockConnections ~= nil) then
	for Index: number, Connection: RBXScriptConnection in pairs(_G.LockConnections) do
		Connection:Disconnect()
	end;
end;
_G.LockConnections = {};
local Lock: (Instance, string, any) -> (Instance, string, any) = function(Instance: Instance, Property: string, Goal: any)
	Instance[Property] = Goal;
	local NewConnection: RBXScriptConnection = Instance:GetPropertyChangedSignal(Property):Connect(function()
		Instance[Property] = Goal;
	end);
	table.insert(_G.LockConnections, NewConnection);
	return NewConnection;
end;

_G.HitboxParts = {};

local Analyse: (BasePart) -> (BasePart) = function(BasePart: BasePart)
	if not (BasePart:IsA("BasePart")) then
		return;
	end;

	if (HitboxExpanderConfiguration.Limb ~= "All") then
		if (type(HitboxExpanderConfiguration.Limb)) == "string" then
			if (BasePart.Name ~= HitboxExpanderConfiguration.Limb) or (BasePart.Name == "HumanoidRootPart") then
				return;
			end;
		else
			if not (table.find(HitboxExpanderConfiguration.Limb, BasePart.Name)) or (BasePart.Name == "HumanoidRootPart") then
				return;
			end;
		end
	end;

	local Character: Model = LocalPlayer.Character;
	if (Character and Character ~= nil) then
		if (BasePart:IsDescendantOf(Character)) then
			return;
		end;
	end;

	local Rig: Model? = BasePart.Parent;
	local Humanoid: Humanoid = Rig:FindFirstChildWhichIsA("Humanoid");
	if (Humanoid and Humanoid ~= nil) then

		table.insert(_G.HitboxParts, BasePart);
		local DestroyedConnection: RBXScriptConnection = BasePart.Destroying:Connect(function()
			table.remove(_G.HitboxParts, table.find(_G.HitboxParts, BasePart));
		end);

		if (HitboxExpanderConfiguration.HumanoidTagRemover == true) then
			Lock(Humanoid, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None);
			Lock(Humanoid, "DisplayName", "");
			Lock(Humanoid, "HealthDisplayDistance", 0);
			Lock(Humanoid, "HealthDisplayType", Enum.HumanoidHealthDisplayType.AlwaysOff);
			Lock(Humanoid, "NameDisplayDistance", 0);
			Lock(Humanoid, "NameOcclusion", Enum.NameOcclusion.OccludeAll);
		end;

		local DiedConnection: RBXScriptSignal = Humanoid.Died:Once(function()
			task.defer(BasePart.Destroy, BasePart);
		end);

		Lock(BasePart, "Size", Vector3.new(HitboxExpanderConfiguration.Size, HitboxExpanderConfiguration.Size, HitboxExpanderConfiguration.Size));
		if (BasePart:IsA("Part")) then
			Lock(BasePart, "Shape", HitboxExpanderConfiguration.Shape);
		end;
		Lock(BasePart, "Color", HitboxExpanderConfiguration.Color);
		Lock(BasePart, "Material", HitboxExpanderConfiguration.Material);
		Lock(BasePart, "MaterialVariant", HitboxExpanderConfiguration.MaterialVariant);
		Lock(BasePart, "Transparency", HitboxExpanderConfiguration.Transparency);
		Lock(BasePart, "Reflectance", HitboxExpanderConfiguration.Reflectance);
		Lock(BasePart, "CastShadow", HitboxExpanderConfiguration.CastShadow);
		Lock(BasePart, "EnableFluidForces", HitboxExpanderConfiguration.EnableFluidForces);
		Lock(BasePart, "CanCollide", HitboxExpanderConfiguration.CanCollide);
		Lock(BasePart, "CanTouch", HitboxExpanderConfiguration.CanTouch);
		Lock(BasePart, "CanQuery", HitboxExpanderConfiguration.CanQuery);
		Lock(BasePart, "Locked", HitboxExpanderConfiguration.Locked);
		Lock(BasePart, "CustomPhysicalProperties", HitboxExpanderConfiguration.CustomPhysicalProperties);
		Lock(BasePart, "Massless", HitboxExpanderConfiguration.Massless);
		Lock(BasePart, "RootPriority", HitboxExpanderConfiguration.RootPriority);

		if (HitboxExpanderConfiguration.Fixes == true) then
			local InstancesToDestroy = {
				"Fire",
				"Sparkles",
				"Smoke",
				"ParticleEmitter",
				"Decal",
				"Texture",
				"SurfaceAppearance",
				"Trail",
				"Beam",
				"SpecialMesh",
				"FileMesh",
				"BlockMesh",
				"CylinderMesh"
			};
			task.spawn(function(Fixes)
				local Analyse2 = function(Instance: Instance)
					local Detected = false;

					for Index: number, ClassName: string in pairs(InstancesToDestroy) do
						if (Instance:IsA(ClassName)) then
							Detected = true;
						end;
					end;

					if (Detected) then
						task.defer(Instance.Destroy, Instance);
					end;
				end;

				for Index: number, Instance: Instance in pairs(BasePart:GetDescendants()) do
					Analyse2(Instance);
				end;
				local DescendantAdded: RBXScriptSignal = BasePart.DescendantAdded:Connect(Analyse2);
			end);
		end;

		if (HitboxExpanderConfiguration.KillAll == true) then
			for Index: number, Joint: JointInstance in pairs(BasePart:GetJoints()) do
				task.defer(Joint.Destroy, Joint);
			end;

			BasePart.Anchored = true;
			local Mouse = LocalPlayer:GetMouse();

			task.spawn(function(Teleport)
				local MouseMoved: RBXScriptSignal = Mouse.Move:Connect(function()
					if (BasePart and BasePart ~= nil) then
						BasePart.CFrame = Mouse.Hit;
					end;
				end);
			end)
		end;

	end;
end;

-- // Script & Connections

for Index: number, BasePart: BasePart in pairs(game:GetDescendants()) do
	Analyse(BasePart);
end;
local DescendantAdded: RBXScriptSignal = game.DescendantAdded:Connect(Analyse);
