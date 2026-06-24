# SolidWorks Automation Skill

通过 Python pywin32 COM 接口控制 SolidWorks 自动化建模的综合 Skill。支持自然语言控制、MCP 协议集成、零件设计、装配体、工程图、文件导出和结果自审查。

## 这个 Skill 能做什么

### 1. 自然语言控制 SolidWorks 建模

无需记忆复杂的 COM API，直接用中文或英文描述建模需求：

> "创建一个直径 50mm、高 100mm 的圆柱体，顶部倒角 2mm，然后抽壳 3mm"

AI 会自动转换为 SolidWorks COM 调用并执行。

### 2. MCP Server 集成（推荐）

通过 MCP (Model Context Protocol) 协议将 SolidWorks 能力暴露给任何支持 MCP 的 AI Agent（TRAE、Cursor、Claude、Codex 等）。

**核心特性：**
- **持久连接**：单例模式保持 SolidWorks 连接，后台 5 秒心跳检测
- **自动重连**：COM 异常时自动恢复，无需手动干预
- **并发安全**：asyncio.Lock + threading.RLock 双重保护
- **28 个工具**：覆盖实体建模、特征编辑、曲面建模、草图约束、文件操作

### 3. 一键测试所有功能

运行单条命令即可依次测试全部 13 项已验证功能，自动生成截图和报告。

### 4. 完整的 Python API 库

10 个模块覆盖 SolidWorks 自动化的全部场景，共 **80+ 个函数/类**：

| 模块 | 功能 |
|------|------|
| `sw_connect` | 连接管理、文档操作、单位转换（14 个函数） |
| `sw_part` | 草图绘制、特征创建（30+ 个函数） |
| `sw_assembly` | 装配体、配合、干涉检查（10 个函数） |
| `sw_drawing` | 工程图、视图、尺寸、BOM、PDF 导出（11 个函数） |
| `sw_export` | STEP/STL/IGES/Parasolid/PDF/DXF 批量导出（10 个函数） |
| `sw_review` | 多视角截图、模型审查报告（14 个函数） |
| `sw_session` | 友好门面类，封装常用工作流（10 个方法） |
| `sw_appearance` | 颜色、材质、外观设置（5 个函数） |
| `mcp_server_v2` | MCP Server，28 个工具 |
| `sw_connection` | 持久连接管理器（15 个方法） |

## 适用场景

- **AI 辅助设计**：用自然语言描述需求，AI 自动生成 SolidWorks 模型
- **批量参数化建模**：通过脚本批量生成系列化零件
- **自动化出图**：从模型自动生成工程图、BOM 表、PDF
- **设计审查自动化**：自动截图、检查模型完整性、生成审查报告
- **格式转换流水线**：批量将 SLDPRT 转换为 STEP/STL/IGES
- **教学演示**：一键执行标准建模流程，每步自动截图记录

## 前置要求

| 项目 | 版本/要求 |
|------|-----------|
| Windows | 10 / 11 (64-bit) |
| SolidWorks | 2020+ (已测试 2024) |
| Python | 3.8+ (64-bit) |
| pywin32 | `pip install pywin32` |

## 快速开始

### 方式一：MCP Server（推荐，用于 AI Agent 集成）

#### 1. 安装 Python 依赖

```bash
pip install pywin32 mcp
```

#### 2. 注册 MCP Server

根据你使用的 AI 客户端，选择对应的配置方式：

**TRAE**

在 TRAE 的 MCP 设置中添加：

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "python",
      "args": ["<SKILL_PATH>\\scripts\\mcp_server_v2.py"]
    }
  }
}
```

**Cursor**

打开 Cursor 设置 → MCP，在 `mcp.json` 中添加：

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "python",
      "args": ["<SKILL_PATH>\\scripts\\mcp_server_v2.py"]
    }
  }
}
```

**Claude Desktop**

编辑 `%APPDATA%\Claude\claude_desktop_config.json`：

```json
{
  "mcpServers": {
    "solidworks": {
      "command": "python",
      "args": ["<SKILL_PATH>\\scripts\\mcp_server_v2.py"]
    }
  }
}
```

**Codex CLI**

```bash
codex mcp add solidworks -- python "<SKILL_PATH>\\scripts\\mcp_server_v2.py"
```

> **`<SKILL_PATH>`** 替换为实际路径，例如：
> - `E:\\AI-SW-Ansys\\codex-skills\\solidworks-automation-test-skills`
> - `D:\\AI-SW-Ansys\\codex-skills\\solidworks-automation-test-skills`

#### 3. 验证 MCP 连接

注册后重启 AI 客户端，输入以下内容测试连接：

> "查询 SolidWorks 连接状态"

AI 应调用 `sw_status` 工具并返回连接信息。

#### 4. 自然语言控制

注册后直接在对话中输入建模需求：

> "创建一个 100x60x40mm 的长方体，添加 R5 圆角，然后抽壳 3mm，保存到桌面"

AI 会自动调用 `sw_create_box` → `sw_fillet` → `sw_shell` → `sw_save`。

更多示例：

> "创建一个直径 50mm、高 100mm 的圆柱体"
> "在当前模型上添加 R3 圆角"
> "将模型导出为 STEP 格式，保存到 E:\\output"
> "截图当前模型并保存"

#### 5. 注意事项

- MCP Server 使用 **stdio 传输模式**，由 AI 客户端自动启动和管理生命周期，**不需要手动双击运行**
- 双击 `start_mcp_server.bat` 仅用于验证 Server 能否加载，启动后等待客户端连接时空闲是正常现象
- 确保 SolidWorks 已安装且版本 >= 2020
- 首次连接时 Server 会自动启动 SolidWorks，请等待 5-10 秒
- 如果连接断开，Server 会自动重连（5 秒心跳检测）

### 方式二：Python 脚本（直接编程）

```python
from sw_session import SolidWorksSession
from sw_connect import mm

session = SolidWorksSession(visible=True)
model = session.new_part()

# 创建圆柱体
session.sketch_manager.InsertSketch(True)
session.sketch_manager.CreateCircleByRadius(0, 0, 0, mm(25))
session.sketch_manager.InsertSketch(True)
session.feature_manager.FeatureExtrusion3(
    True, False, True, 0, 0, mm(100), 0,
    False, False, False, False, 0, 0,
    False, False, False, False, True, False, True, 0, 0, False,
)

session.save(model, r"E:\model\cylinder.sldprt")
```

### 方式三：一键测试（验证环境）

```bash
cd scripts
python run_all_verified_tests.py
```

依次测试 13 项功能，输出：
- `test_report.json` / `test_report.md` — 测试报告
- `test_*_isometric.bmp` — 每步截图
- `all_verified_tests_model.sldprt` — 最终模型

## MCP 工具完整列表

| 类别 | 工具 | 说明 |
|------|------|------|
| **连接** | `sw_status` | 查询连接状态、运行时间、重连次数 |
| **连接** | `sw_reconnect` | 手动重连 SolidWorks |
| **实体** | `sw_create_box` | 创建长方体（宽x高x深 mm） |
| **实体** | `sw_create_cylinder` | 创建圆柱体（半径x高 mm） |
| **实体** | `sw_extrude_boss` | 拉伸凸台 |
| **实体** | `sw_extrude_cut` | 拉伸切除 |
| **实体** | `sw_revolve_boss` | 旋转凸台 |
| **特征** | `sw_fillet` | 圆角（指定半径和边位置） |
| **特征** | `sw_chamfer` | 倒角 |
| **特征** | `sw_shell` | 抽壳（指定壁厚和面） |
| **特征** | `sw_mirror` | 镜像特征 |
| **特征** | `sw_circular_pattern` | 圆形阵列 |
| **曲面** | `sw_surface_loft` | 放样曲面 |
| **曲面** | `sw_surface_sweep` | 扫描曲面 |
| **曲面** | `sw_surface_boundary` | 边界曲面 |
| **曲面** | `sw_surface_offset` | 偏移曲面 |
| **曲面** | `sw_surface_fill` | 填充曲面 |
| **曲面** | `sw_surface_knit` | 缝合曲面 |
| **曲面** | `sw_thicken` | 曲面加厚 |
| **草图** | `sw_sketch_rectangle` | 矩形草图 |
| **草图** | `sw_sketch_circle` | 圆形草图 |
| **草图** | `sw_sketch_line` | 直线草图 |
| **约束** | `sw_add_dimension` | 尺寸标注 |
| **约束** | `sw_add_constraint` | 几何约束（水平/垂直/同心等） |
| **文件** | `sw_save` | 保存 .sldprt |
| **文件** | `sw_export` | 导出 STEP/STL/IGES/PDF |
| **视图** | `sw_screenshot` | 截图（等轴测/前视/上视/右视） |
| **信息** | `sw_get_info` | 获取模型信息（实体数、面数、包围盒） |

## 已验证功能状态

在 SolidWorks 2024 + Python 3.10 + pywin32 环境中实测：

| # | 功能 | 状态 | 说明 |
|---|------|------|------|
| 1 | 拉伸凸台 | 已验证 | FeatureExtrusion3 |
| 2 | 拉伸切除 | 已验证 | FeatureCut4 |
| 3 | 旋转凸台 | 已验证 | FeatureRevolve2 |
| 4 | 圆角 | 已验证 | FeatureFillet |
| 5 | 倒角 | 已验证 | InsertFeatureChamfer |
| 6 | 抽壳 | 已验证 | InsertFeatureShell |
| 7 | 扫描 | 已知限制 | API 不存在，仅创建草图 |
| 8 | 放样 | 已知限制 | API 不存在，仅创建草图 |
| 9 | 线性阵列 | 已知限制 | 选择兼容性问题 |
| 10 | 圆形阵列 | 已验证 | FeatureCircularPattern |
| 11 | 镜像特征 | 已验证 | InsertMirrorFeature2 |
| 12 | 基准面 | 已知限制 | 参数兼容性问题 |
| 13 | 基准轴 | 已验证 | InsertAxis2 |

> **已知限制**：标记为"已知限制"的功能在测试中会优雅降级（创建草图/选择元素），不会导致失败。实际建模中可通过 SolidWorks 宏录制获取对应版本可用的 API。

## 项目结构

```
solidworks-automation-test-skills/
├── README.md                          # 本文件
├── SKILL.md                           # Codex Skill 入口（YAML frontmatter）
├── agents/
│   └── openai.yaml                    # UI 元数据
├── scripts/                           # Python 模块
│   ├── __init__.py
│   ├── mcp_server_v2.py              # MCP Server（28 个工具）
│   ├── sw_connection.py              # 持久连接管理器
│   ├── sw_connect.py                 # 连接/文档/单位转换
│   ├── sw_part.py                    # 草图/特征
│   ├── sw_assembly.py                # 装配体
│   ├── sw_drawing.py                 # 工程图
│   ├── sw_export.py                  # 文件导出
│   ├── sw_review.py                  # 结果审查
│   ├── sw_session.py                 # 门面类
│   ├── sw_appearance.py              # 外观材质
│   └── run_all_verified_tests.py     # 一键测试脚本
├── references/                        # 参考文档
│   ├── modeling-experience.md
│   ├── verified-action-log.md
│   ├── part-modeling.md
│   ├── assembly.md
│   ├── drawing.md
│   ├── export.md
│   └── troubleshooting.md
├── run_tests.bat                      # Windows 一键运行全部测试（双击即可）
└── start_mcp_server.bat               # Windows 一键启动 MCP Server（双击即可）
```

## 完整 API 功能说明

### sw_connect.py — 连接与文档管理（14 个函数）

| 函数 | 功能 |
|------|------|
| `connect_solidworks()` | 连接 SolidWorks（支持复用已有实例、自动检测版本、启动新实例） |
| `get_sw_version()` | 获取 SolidWorks 版本信息 |
| `find_template()` | 自动查找 SolidWorks 文档模板 |
| `new_document(sw, type)` | 创建新文档（part/assembly/drawing） |
| `open_document(sw, path)` | 打开已有文档（支持只读、静默模式） |
| `open_document_stable(sw, path)` | 更稳定的文档打开器，使用 OpenDoc7 |
| `save_document(model, path)` | 保存文档（支持另存为） |
| `mm(value)` | 毫米转米（SolidWorks API 使用米为单位） |
| `deg(value)` | 角度转弧度 |
| `get_com_member(obj, name)` | 兼容 pywin32 属性/方法动态绑定 |
| `create_empty_dispatch_variant()` | 创建空的 COM Dispatch 参数 |
| `normalize_doc_type(type)` | 规范化文档类型名称 |

### sw_part.py — 零件建模（30+ 个函数）

**草图绘制：**

| 函数 | 功能 |
|------|------|
| `start_sketch(model, plane)` | 在指定基准面上开始草图（支持中英文名称） |
| `end_sketch(model)` | 退出当前草图 |
| `sketch(model, plane)` | 草图上下文管理器（with 语句） |
| `current_sketch_name(model)` | 获取当前草图名称 |
| `sketch_line(model, x1, y1, x2, y2)` | 画直线 |
| `sketch_rectangle(model, cx, cy, w, h)` | 以中心点画矩形 |
| `sketch_corner_rectangle(model, x1, y1, x2, y2)` | 以对角线画矩形 |
| `sketch_circle(model, cx, cy, r)` | 画圆 |
| `sketch_arc(model, cx, cy, r, start, end)` | 画圆弧 |
| `sketch_polygon(model, cx, cy, r, n)` | 画正多边形（内切圆方式） |
| `sketch_slot(model, cx, cy, w, h)` | 画槽口 |
| `sketch_spline(model, points)` | 画样条曲线 |
| `sketch_point(model, x, y)` | 画草图点 |
| `sketch_text(model, text, x, y, size)` | 插入草图文字 |
| `add_dimension(model, x, y)` | 在指定位置添加尺寸标注 |
| `add_sketch_relation(model, type)` | 添加草图几何关系（水平/垂直/同心等） |

**特征创建：**

| 函数 | 功能 |
|------|------|
| `extrude_boss(model, sketch, depth)` | 凸台拉伸 |
| `extrude_cut(model, sketch, depth)` | 切除拉伸（支持完全贯穿和有限深度） |
| `extrude_midplane(model, sketch, depth)` | 中面拉伸（两侧对称拉伸） |
| `revolve_boss(model, sketch, axis)` | 旋转凸台 |
| `fillet(model, edges, radius)` | 倒圆角 |
| `chamfer(model, edges, distance)` | 倒角 |
| `shell(model, faces, thickness)` | 抽壳 |
| `mirror_feature(model, feature, plane)` | 镜像特征 |
| `linear_pattern(model, feature, dir, spacing, count)` | 线性阵列 |
| `circular_pattern(model, feature, axis, count)` | 圆形阵列 |
| `hole_wizard(model, type, pos, diameter, depth)` | 异型孔向导 |
| `rib(model, sketch, thickness)` | 筋特征 |
| `scan(model, profile, path)` | 扫描特征 |
| `loft(model, sections)` | 放样特征 |

### sw_assembly.py — 装配体操作（10 个函数）

| 函数 | 功能 |
|------|------|
| `add_component(assembly, path, x, y, z)` | 向装配体添加零部件 |
| `add_mate_coincident(assembly, comp1, comp2)` | 添加重合配合 |
| `add_mate_concentric(assembly, comp1, comp2)` | 添加同心配合 |
| `add_mate_distance(assembly, comp1, comp2, dist)` | 添加距离配合 |
| `add_mate_parallel(assembly, comp1, comp2)` | 添加平行配合 |
| `get_components(assembly, all_levels)` | 获取装配体中的所有组件 |
| `suppress_component(assembly, comp)` | 压缩（隐藏）组件 |
| `unsuppress_component(assembly, comp)` | 解压缩（显示）组件 |
| `replace_component(assembly, old_comp, new_path)` | 替换装配体中的组件 |
| `get_interference_detection(assembly)` | 运行干涉检查 |

### sw_drawing.py — 工程图操作（11 个函数）

| 函数 | 功能 |
|------|------|
| `create_standard_views(drawing, model, sheet)` | 创建标准三视图（第三角投影法） |
| `add_view(drawing, model, sheet, orientation, scale)` | 添加单个视图 |
| `add_section_view(drawing, sheet, line)` | 创建剖视图 |
| `add_detail_view(drawing, sheet, circle, scale)` | 创建局部放大视图 |
| `insert_dimensions(drawing, sheet, view)` | 自动标注尺寸（模型项目） |
| `add_note(drawing, sheet, text, x, y)` | 添加注释 |
| `insert_bom_table(drawing, sheet, anchor)` | 插入 BOM 表 |
| `set_sheet_format(drawing, sheet, format)` | 设置图纸格式（图框） |
| `add_sheet(drawing, size)` | 添加新图纸 |
| `get_all_views(drawing, sheet)` | 获取当前图纸上的所有视图 |
| `export_sheet_to_pdf(drawing, sheet, path)` | 将工程图导出为 PDF |

### sw_export.py — 文件导出（10 个函数）

| 函数 | 功能 |
|------|------|
| `export_to_step(model, path)` | 导出为 STEP 格式 |
| `export_to_stl(model, path, quality)` | 导出为 STL 格式（支持 coarse/fine） |
| `export_to_iges(model, path)` | 导出为 IGES 格式 |
| `export_to_parasolid(model, path)` | 导出为 Parasolid (.x_t) 格式 |
| `export_to_pdf(drawing, path)` | 导出工程图为 PDF |
| `export_to_dxf(model, path)` | 导出为 DXF/DWG 格式 |
| `export_flat_pattern_dxf(sheet_metal, path)` | 导出钣金展开图为 DXF |
| `batch_export(files, formats, output_dir)` | 批量导出多个文件 |
| `_export_generic(model, path, format)` | 通用导出函数 |

### sw_review.py — 结果审查（14 个函数）

| 函数 | 功能 |
|------|------|
| `zoom_to_fit(model)` | 缩放到适合窗口并刷新图形 |
| `set_standard_view(model, view)` | 设置标准视图方向 |
| `save_preview(model, path, view, width, height)` | 导出当前模型预览图（BMP） |
| `save_review_previews(model, output_dir, basename)` | 导出多视角预览图（等轴测/前视/俯视/右视） |
| `inspect_bmp_preview(path)` | 对 BMP 预览图做轻量检查 |
| `collect_model_summary(model)` | 收集基础模型摘要 |
| `build_review_report(model, previews, outputs)` | 生成结构化审查报告数据 |
| `evaluate_review_report(report)` | 对审查报告做规则评分 |
| `write_review_report(report, path)` | 写入 JSON 审查报告 |
| `write_markdown_summary(report, path)` | 写入 Markdown 审查摘要 |
| `run_review(model, output_dir, basename, views)` | 一站式运行自审查 |

### sw_session.py — 友好会话 API（10 个方法）

| 方法 | 功能 |
|------|------|
| `SolidWorksSession(version)` | 创建会话并连接 SolidWorks |
| `.active_doc()` | 返回当前活动文档 |
| `.new(type)` | 新建文档 |
| `.new_part()` | 新建零件文档 |
| `.new_assembly()` | 新建装配体文档 |
| `.new_drawing()` | 新建工程图文档 |
| `.open(path)` | 打开文档 |
| `.save(model, path)` | 保存文档 |
| `.export(model, path)` | 按扩展名导出文档 |
| `.close(model)` | 关闭文档 |

### sw_appearance.py — 外观与材质（5 个函数）

| 函数 | 功能 |
|------|------|
| `rgb01(color)` | 将颜色转换为 0..1 RGB（支持预设名/十六进制/RGB 元组） |
| `material_values(...)` | 生成 SolidWorks 材质属性数组 |
| `set_document_appearance(model, color)` | 设置文档级外观颜色 |
| `set_feature_appearance(model, feature, color)` | 设置特征级外观颜色 |
| `set_component_appearance(model, component, color)` | 设置装配体组件外观颜色 |
| `apply_named_appearance(model, target, color)` | 给任意对象应用预设外观 |

### sw_connection.py — 持久连接管理器（15 个方法）

| 方法 | 功能 |
|------|------|
| `SolidWorksConnectionManager(visible, heartbeat_interval)` | 创建持久连接管理器（单例） |
| `._check_com_alive()` | 检查 COM 对象是否仍然有效 |
| `._connect()` | 建立 SolidWorks 连接 |
| `._disconnect()` | 断开连接 |
| `.reconnect()` | 手动重连 |
| `.ensure_connected()` | 确保连接有效，必要时自动重连 |
| `._heartbeat_loop()` | 后台心跳检测循环（每 5 秒） |
| `.start_heartbeat()` | 启动心跳线程 |
| `.stop_heartbeat()` | 停止心跳线程 |
| `.get_status()` | 获取连接状态（connected, uptime, reconnect_count, errors） |
| `.async_ensure_connected()` | 异步版本的确保连接 |
| `.async_get_status()` | 异步版本的状态查询 |
| `.async_execute(func, *args, **kwargs)` | 异步执行 COM 操作（带锁保护和异常处理） |
| `get_connection_manager(...)` | 获取全局连接管理器实例 |
| `shutdown_connection_manager()` | 关闭连接管理器 |

## 常见问题

**Q: 连接 SolidWorks 时提示 "无法找到 SolidWorks 实例"？**
A: 确保 SolidWorks 已安装且版本 >= 2020。首次连接时会自动启动 SolidWorks，请等待 5-10 秒。

**Q: MCP Server 启动后没有响应？**
A: MCP Server 使用 stdio 传输模式，需要通过 MCP 客户端（如 TRAE）连接。命令行直接运行会等待输入，这是正常行为。

**Q: 某些 API 返回 "非选择性的参数"？**
A: 这是 SolidWorks 中文版与 API 的兼容性问题。部分 API（如 InsertRefPlane、FeatureLinearPattern）需要特定的选择状态。测试脚本已处理为"已知限制"，不会导致失败。

**Q: 如何获取某个特征的准确中文名称？**
A: 使用 `model.FeatureByName("凸台-拉伸1")`。SolidWorks 中文版生成中文特征名，英文版生成英文特征名，需与当前语言环境匹配。

**Q: 可以同时在多个 SolidWorks 实例上运行吗？**
A: 当前版本使用单例连接管理器，同一时间只连接一个 SolidWorks 实例。如需多实例支持，可修改 `sw_connection.py` 创建多个连接管理器实例。

## 参考文档

| 文档 | 内容 |
|------|------|
| `references/modeling-experience.md` | 旋转体/箱体建模模式、可靠代码模式、失败命令替代方案 |
| `references/verified-action-log.md` | 23 项已验证 + 5 项未通过动作的完整代码片段 |
| `references/part-modeling.md` | 草图方法速查、FeatureExtrusion3/Cut4/Revolve2 参数详解 |
| `references/assembly.md` | AddMate5 配合类型、组件操作、干涉检查 |
| `references/drawing.md` | 视图创建、尺寸标注、BOM 表、PDF 导出 |
| `references/export.md` | 支持格式、SaveAs 错误码、STL 质量设置 |
| `references/troubleshooting.md` | 连接问题、类型错误、性能优化、版本号对照表 |

## 许可证

MIT License — 自由使用、修改和分发。
