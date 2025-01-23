local HitboxExpanderConfiguration: {Limb: string, Size: number, Shape: Enum.PartType, Color: Color3, Material: Enum.Material, MaterialVariant: string, Transparency: number, Reflectance: number, CastShadow: boolean, EnableFluidForces: boolean, CanCollide: boolean, CanTouch: boolean, CanQuery: boolean, Locked: boolean, CustomPhysicalProperties: PhysicalProperties, Massless: boolean, RootPriority: number, Fixes: boolean} = {
	-- Basic
	PanicKey = Enum.KeyCode.Pause, -- Stops the script completely.
	Limb = {"Head"}, -- "All": expands every limb no matter their name, except the Root.
	Size = 15,
	
	-- Checks
	HumanoidCheck = true, -- Checks if there is a Humanoid.
	IgnoreUnanchoredUnweldedUnforced = true, -- If the above is false, it will ignore parts that are unanchored, unwelded & unforced.
	DeadCheck = true, -- Checks if the Humanoid is dead.
	FriendCheck = false, -- Checks if the player is friend's with the exploiter.
	InvisibleCheck = false, -- Checks if the player is inivisble.
	InvisibleValue = 1, -- If it's above or this transparent, it'll be ignored.
	TeamCheck = false, -- Checks if the player is in the same team as the exploiter.
	PlayerCheck = false, -- Checks if it's a actual player, not a BOT.

	-- Customization
	Shape = Enum.PartType.Ball,
	Color = Color3.fromRGB(255, 0, 255),
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
	RootPriority = 127,

	-- Experimental
	Fixes = true, -- Removes particles, decals, textures, smoothens textures, etc.
	HumanoidTagRemover = true, -- Removes the annoying vision blocking humanoid tag.
	KillAll = false, -- Teleports hitboxes to your mouse's hit CFrame. OP in games like Arsenal.
	NoCharacterMeshes = true, -- Removes CharacterMeshes (R6) to reveal true hitbox size.
};

-- // Variables

local Players: Players = game:GetService("Players");
local LocalPlayer: Player = Players.LocalPlayer;
local UIS = game:GetService("UserInputService");

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
	if (HitboxExpanderConfiguration.HumanoidCheck == true) then
		if not (Humanoid) then
			return;
		end;
	else
		if not (Humanoid) then
			if (HitboxExpanderConfiguration.IgnoreUnanchoredUnweldedUnforced == true) then
				if (BasePart.Anchored == false) then
					local AllowedInstances = 0
					for Index: number, Instance: Instance in pairs(BasePart:GetDescendants()) do
						local AllowedClasses = {
							"Weld",
							"ManualWeld",
							
							"Motor",
							"Motor6D",
							"MotorFeature",
							"VelocityMotor",
							
							"Glue",
							"ManualGlue",
							
							"Rotate",
							"RotateV",
							"RotateP",
							"RotationCurve",
							
							"CylindricalConstraint",
							"WeldConstraint",
							"RodConstraint",
							"RopeConstraint",
							"HingeConstraint",
							"PlaneConstraint",
							"RigidConstraint",
							"SpringConstraint",
							"AnimationConstraint",
							"BallSocketConstraint",
							"UniversalConstraint",
							"PrismaticConstraint",
							"NoCollisionConstraint",
							"TorsionSpringConstraint"
						}
						if (table.find(AllowedClasses, Instance.ClassName)) then
							AllowedInstances += 1;
						end;
					end;
					if (AllowedInstances == 0) then
						return;
					end;
				end;
			end;
		end;
	end;
	
	if (HitboxExpanderConfiguration.InvisibleCheck == true) then
		if (BasePart.Transparency >= HitboxExpanderConfiguration.InvisibleValue) then
			return;
		end;
	end;
	
	local FoundPlayer: Player = Players:FindFirstChild(Rig.Name);
	if (FoundPlayer and FoundPlayer ~= nil) then
		if (FoundPlayer:IsFriendsWith(LocalPlayer.UserId) or LocalPlayer:IsFriendsWith(FoundPlayer.UserId)) then
			if (HitboxExpanderConfiguration.FriendCheck == true) then
				return;
			end
		end
		if (FoundPlayer.Team == LocalPlayer.Team) then
			if (HitboxExpanderConfiguration.TeamCheck == true) then
				return;
			end
		end
	else
		if (HitboxExpanderConfiguration.PlayerCheck == true) then
			return;
		end;
	end;
	
	if (HitboxExpanderConfiguration.NoCharacterMeshes == true) then
		for Index: number, CharacterMesh: CharacterMesh in pairs(Rig:GetDescendants()) do
			if (CharacterMesh:IsA("CharacterMesh")) then
				task.defer(CharacterMesh.Destroy, CharacterMesh)
			end;
		end;
	end;

	table.insert(_G.HitboxParts, BasePart);
	local DestroyedConnection: RBXScriptConnection = BasePart.Destroying:Connect(function()
		table.remove(_G.HitboxParts, table.find(_G.HitboxParts, BasePart));
	end);

	if (Humanoid and Humanoid ~= nil) then
		if (HitboxExpanderConfiguration.HumanoidTagRemover == true) then
			Lock(Humanoid, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None);
			Lock(Humanoid, "DisplayName", "");
			Lock(Humanoid, "HealthDisplayDistance", 0);
			Lock(Humanoid, "HealthDisplayType", Enum.HumanoidHealthDisplayType.AlwaysOff);
			Lock(Humanoid, "NameDisplayDistance", 0);
			Lock(Humanoid, "NameOcclusion", Enum.NameOcclusion.OccludeAll);
		end;
	end

	if (Humanoid and Humanoid ~= nil) then
		if (HitboxExpanderConfiguration.DeadCheck == true) then
			local DiedConnection: RBXScriptSignal = Humanoid.Died:Once(function()
				task.defer(BasePart.Destroy, BasePart);
			end);
		end
	end

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

-- // Script & Connections

for Index: number, BasePart: BasePart in pairs(game:GetDescendants()) do
	Analyse(BasePart);
end;
local DescendantAdded: RBXScriptConnection = game.DescendantAdded:Connect(Analyse);

local InputBegan_PanicKey: RBXScriptConnection = UIS.InputBegan:Connect(function(InputObject: InputObject, Processed: RBXScriptSignal)
	if (Processed) then return end;
	if (InputObject.KeyCode == HitboxExpanderConfiguration.PanicKey) then
		if (_G.LockConnections ~= nil) then
			for Index: number, Connection: RBXScriptConnection in pairs(_G.LockConnections) do
				Connection:Disconnect()
			end;
		end;
		_G.HitboxParts = {};
		DescendantAdded:Disconnect()
	end;
end);
