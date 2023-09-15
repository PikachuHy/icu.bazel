load("@rules_cc//cc:action_names.bzl", "CPP_COMPILE_ACTION_NAME", "CPP_LINK_STATIC_LIBRARY_ACTION_NAME")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")

def _gen_icudata_impl(ctx):
    icupkg_in = ctx.actions.declare_file("icupkg.in")
    icudata_lst = ctx.actions.declare_file("icudata.lst")
    icudata = ctx.actions.declare_file("libicudata.a")
    cc_info_list = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            cc_info_list.append(dep[CcInfo])
    cc_info = cc_common.merge_cc_infos(cc_infos = cc_info_list)

    include_flags = []
    for item in cc_info.compilation_context.system_includes.to_list():
        include_flags.append("-I" + item)
    cc_toolchain = find_cc_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        cc_toolchain = cc_toolchain,
        ctx = ctx,
        language = "c++",
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    variables = cc_common.create_compile_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        system_include_directories = cc_info.compilation_context.system_includes,
    )
    env = cc_common.get_environment_variables(
        variables = variables,
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
    )
    print("env", env)
    cc = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
    )
    print("cc", cc)
    ar = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
    )
    print("ar", ar)
    ctx.actions.expand_template(
        template = ctx.file.icupkg_in_tpl,
        output = icupkg_in,
        substitutions = {
            "@cc@": cc,
            "@ar@": ar,
            "@cc_flags@": " ".join(include_flags),
            "@assembly_type@": ctx.attr.assembly_type,
        },
    )

    args = []
    args.append(ctx.file.pkgdata.path)
    args.append("-O")
    args.append(icupkg_in.path)
    args.append("-c")
    args.append("-s")
    args.append(icudata_lst.dirname)
    args.append("-d")
    args.append(icudata.dirname)
    args.append("-e")
    args.append("icudt73")
    args.append("-T")
    args.append(icudata.dirname)
    args.append("-p")
    args.append("icudt73l")
    args.append("-m")
    args.append("static")
    args.append("-r")
    args.append("73.2")
    args.append("-L")
    args.append("icudata")
    if ctx.attr.without_assembly:
        args.append("-w")
    args.append("-q")

    # args.append("-v")
    args.append(icudata_lst.path)

    build_sh = ctx.actions.declare_file("build.sh")
    ctx.actions.expand_template(
        template = ctx.file.build_tpl,
        output = build_sh,
        substitutions = {
            "@icupkg@": ctx.file.icupkg.path,
            "@icudt_data@": ctx.file.icudt_data.path,
            "@icudata_dir@": icudata_lst.dirname,
            "@icudata_lst@": icudata_lst.path,
            "@pkgdata@": " ".join(args),
        },
    )
    ctx.actions.run_shell(
        inputs = depset(
            direct = [icupkg_in, build_sh, ctx.file.icupkg, ctx.file.icudt_data, ctx.file.pkgdata] + ctx.files.build_data,
            transitive = [cc_toolchain.all_files, cc_info.compilation_context.headers],
        ),
        outputs = [icudata_lst, icudata],
        command = "bash " + build_sh.path,
        env = env,
    )

    return [DefaultInfo(files = depset([
        icudata,
    ]))]

gen_icudata = rule(
    implementation = _gen_icudata_impl,
    fragments = ["cpp"],
    attrs = {
        "icupkg": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
        ),
        "pkgdata": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
        ),
        "icupkg_in_tpl": attr.label(
            allow_single_file = True,
        ),
        "build_tpl": attr.label(
            allow_single_file = True,
        ),
        "icudt_data": attr.label(
            allow_single_file = True,
        ),
        "deps": attr.label_list(),
        "build_data": attr.label_list(),
        "without_assembly": attr.bool(default = False),
        "assembly_type": attr.string(),
        "_cc_toolchain": attr.label(
            default = Label(
                "@rules_cc//cc:current_cc_toolchain",  # copybara-use-repo-external-label
            ),
        ),
    },
)
